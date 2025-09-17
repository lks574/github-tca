import ComposableArchitecture
import SwiftUI

@Reducer
struct ExploreReducer {
  @ObservableState
  struct State: Equatable {
    var searchItems: [ExploreModel.SearchItem] = .default
    var popularRepositories: [ExploreModel.PopularRepository] = .default
    var activityItems: [ExploreModel.ActivityItem] = .default
    
    // MARK: - Search State
    var searchQuery: String = ""
    var searchResults: [ExploreModel.PopularRepository] = []
    var isSearching: Bool = false
    var searchError: String?
    var hasSearched: Bool = false
    
    // MARK: - Pagination State
    var currentPage: Int = 1
    var totalCount: Int = 0
    var canLoadMore: Bool = false
    var isLoadingMore: Bool = false
    
    // MARK: - Category State
    var selectedCategory: SearchCategory = .all
    var showingSearchResults: Bool = false
  }
  
  enum SearchCategory: String, CaseIterable {
    case all = "전체"
    case swift = "Swift"
    case ios = "iOS"
    case tca = "TCA"
    case repositories = "리포지토리"
    
    var searchParameters: GitHubSearchParameters {
      switch self {
      case .all:
        return GitHubSearchParameters(query: "", sort: .stars, order: .desc)
      case .swift:
        return .swiftRepositories()
      case .ios:
        return .iOSRepositories()
      case .tca:
        return .tcaRepositories()
      case .repositories:
        return GitHubSearchParameters(query: "", sort: .stars, order: .desc)
      }
    }
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case searchItemTapped(ExploreModel.SearchItem)
    case repositoryTapped(ExploreModel.PopularRepository)
    case activityItemTapped(ExploreModel.ActivityItem)
    
    // MARK: - Search Actions
    case searchQueryChanged(String)
    case searchSubmitted
    case searchCancelled
    case categorySelected(SearchCategory)
    case clearSearch
    
    // MARK: - API Response Actions
    case searchResponse(Result<GitHubSearchResponse, Error>)
    case loadMoreResponse(Result<GitHubSearchResponse, Error>)
    
    // MARK: - Pagination Actions
    case loadMore
    case refreshSearch
    
    // MARK: - Popular Repositories Actions
    case loadPopularRepositories
    case popularRepositoriesResponse(Result<GitHubSearchResponse, Error>)
    
    // MARK: - Lifecycle Actions
    case onAppear
  }

  @Dependency(\.gitHubClient) var gitHubClient
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      // MARK: - Search Actions
      case let .searchQueryChanged(query):
        state.searchQuery = query
        if query.isEmpty {
          state.showingSearchResults = false
          state.searchResults = []
          state.hasSearched = false
          state.searchError = nil
        }
        return .none
        
      case .searchSubmitted:
        guard !state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          return .none
        }
        
        state.isSearching = true
        state.searchError = nil
        state.currentPage = 1
        state.showingSearchResults = true
        state.hasSearched = true
        
        return .run { [query = state.searchQuery, category = state.selectedCategory] send in
          await send(.searchResponse(
            Result {
              var parameters = category.searchParameters
              if !query.isEmpty {
                parameters = GitHubSearchParameters(
                  query: category == .all ? query : "\(query) \(category.searchParameters.query)",
                  sort: parameters.sort,
                  order: parameters.order,
                  page: 1,
                  perPage: 20
                )
              }
              return try await gitHubClient.searchRepositories(parameters)
            }
          ))
        }
        
      case .searchCancelled:
        state.isSearching = false
        state.showingSearchResults = false
        state.searchResults = []
        state.searchQuery = ""
        state.hasSearched = false
        state.searchError = nil
        return .none
        
      case let .categorySelected(category):
        state.selectedCategory = category
        if state.hasSearched && !state.searchQuery.isEmpty {
          return .send(.searchSubmitted)
        }
        return .none
        
      case .clearSearch:
        state.searchQuery = ""
        state.searchResults = []
        state.showingSearchResults = false
        state.hasSearched = false
        state.searchError = nil
        state.isSearching = false
        state.currentPage = 1
        return .none
        
      // MARK: - API Response Actions
      case let .searchResponse(.success(response)):
        state.isSearching = false
        state.searchResults = response.items.map { $0.toPopularRepository() }
        state.totalCount = response.totalCount
        state.canLoadMore = response.items.count >= 20 && state.searchResults.count < response.totalCount
        state.searchError = nil
        return .none
        
      case let .searchResponse(.failure(error)):
        state.isSearching = false
        state.searchResults = []
        state.canLoadMore = false
        if let gitHubError = error as? GitHubError {
          state.searchError = gitHubError.localizedDescription
        } else {
          state.searchError = "검색 중 오류가 발생했습니다."
        }
        return .none
        
      case .loadMore:
        guard state.canLoadMore && !state.isLoadingMore else {
          return .none
        }
        
        state.isLoadingMore = true
        state.currentPage += 1
        
        return .run { [query = state.searchQuery, category = state.selectedCategory, page = state.currentPage] send in
          await send(.loadMoreResponse(
            Result {
              var parameters = category.searchParameters
              if !query.isEmpty {
                parameters = GitHubSearchParameters(
                  query: category == .all ? query : "\(query) \(category.searchParameters.query)",
                  sort: parameters.sort,
                  order: parameters.order,
                  page: page,
                  perPage: 20
                )
              }
              return try await gitHubClient.searchRepositories(parameters)
            }
          ))
        }
        
      case let .loadMoreResponse(.success(response)):
        state.isLoadingMore = false
        let newRepositories = response.items.map { $0.toPopularRepository() }
        state.searchResults.append(contentsOf: newRepositories)
        state.canLoadMore = newRepositories.count >= 20 && state.searchResults.count < state.totalCount
        return .none
        
      case let .loadMoreResponse(.failure(error)):
        state.isLoadingMore = false
        state.currentPage -= 1 // 실패시 페이지 롤백
        if let gitHubError = error as? GitHubError {
          state.searchError = gitHubError.localizedDescription
        } else {
          state.searchError = "더 많은 결과를 불러오는 중 오류가 발생했습니다."
        }
        return .none
        
      case .refreshSearch:
        guard state.hasSearched else {
          return .none
        }
        return .send(.searchSubmitted)
        
      // MARK: - Popular Repositories Actions
      case .loadPopularRepositories:
        return .run { send in
          await send(.popularRepositoriesResponse(
            Result {
              try await gitHubClient.searchRepositories(.swiftRepositories(perPage: 10))
            }
          ))
        }
        
      case let .popularRepositoriesResponse(.success(response)):
        state.popularRepositories = response.items.map { $0.toPopularRepository() }
        return .none
        
      case let .popularRepositoriesResponse(.failure(error)):
        print("인기 레포지토리 로딩 실패: \(error)")
        return .none
        
      // MARK: - Original Actions
      case let .searchItemTapped(item):
        if item.title.contains("인기") {
          state.selectedCategory = .repositories
          state.searchQuery = ""
          state.showingSearchResults = true
          state.hasSearched = true
          return .send(.loadPopularRepositories)
        }
        return .run { _ in
          print("\(item.title) 검색 아이템 선택됨")
        }
        
      case let .repositoryTapped(repository):
        return .run { _ in
          print("\(repository.fullName) 리포지토리 선택됨")
          // TODO: 레포지토리 상세 화면으로 이동
        }
        
      case let .activityItemTapped(activity):
        return .run { _ in
          print("\(activity.fullName) 활동 아이템 선택됨")
          // TODO: 레포지토리 상세 화면으로 이동
        }
        
      // MARK: - Lifecycle Actions
      case .onAppear:
        // 앱 시작시 인기 레포지토리를 미리 로드
        if state.popularRepositories.isEmpty || state.popularRepositories == .default {
          return .send(.loadPopularRepositories)
        }
        return .none
      }
    }
  }
}

// MARK: - Computed Properties Extension
extension ExploreReducer.State {
  
  /// 현재 표시할 레포지토리 목록
  var displayRepositories: [ExploreModel.PopularRepository] {
    showingSearchResults ? searchResults : popularRepositories
  }
  
  /// 로딩 상태 여부
  var isLoading: Bool {
    isSearching || isLoadingMore
  }
  
  /// 에러 표시 여부
  var shouldShowError: Bool {
    searchError != nil
  }
  
  /// 빈 결과 표시 여부
  var shouldShowEmptyState: Bool {
    hasSearched && searchResults.isEmpty && !isSearching && searchError == nil
  }
  
  /// 검색 결과 개수 텍스트
  var searchResultsText: String {
    if isSearching {
      return "검색 중..."
    } else if hasSearched && !searchResults.isEmpty {
      return "\(totalCount.formatted())개의 결과"
    } else {
      return ""
    }
  }
}

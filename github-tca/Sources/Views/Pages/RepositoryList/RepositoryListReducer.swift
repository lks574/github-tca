import Foundation
import ComposableArchitecture

@Reducer
struct RepositoryListReducer {

  @Dependency(\.navigation) var navigation
  @Dependency(\.gitHubClient) var gitHubClient

  @ObservableState
  struct State: Equatable, PaginationErrorHandlingState {
    var repositories: [ProfileModel.RepositoryItem] = []
    var searchQuery: String = ""
    var selectedFilter: RepositoryFilter = .all
    var selectedSort: RepositorySort = .updated
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var isSearching: Bool = false
    var hasMore: Bool = true
    var currentPage: Int = 1
    var errorMessage: String?
    
    // 검색 관련
    var searchResults: [ProfileModel.RepositoryItem] = []
    var isShowingSearchResults: Bool = false
    
    // 계산된 속성
    var displayRepositories: [ProfileModel.RepositoryItem] {
      isShowingSearchResults ? searchResults : repositories
    }
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    
    // 라이프사이클
    case onAppear
    case refresh
    
    // 검색
    case searchQueryChanged(String)
    case searchSubmitted
    case searchCancelled
    case searchResponse(Result<[ProfileModel.RepositoryItem], Error>)
    
    // 필터링 & 정렬
    case filterChanged(RepositoryFilter)
    case sortChanged(RepositorySort)
    
    // 리포지토리 액션
    case repositoryTapped(ProfileModel.RepositoryItem)
    case loadMore
    case loadMoreResponse(Result<[ProfileModel.RepositoryItem], Error>)
    case repositoriesResponse(Result<[ProfileModel.RepositoryItem], Error>)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        if state.repositories.isEmpty {
          return .send(.refresh)
        }
        return .none
        
      case .refresh:
        state.isLoading = true
        state.errorMessage = nil
        state.currentPage = 1
        state.hasMore = true
        
        return .run { [filter = state.selectedFilter, sort = state.selectedSort] send in
          do {
            let repositories = try await gitHubClient.getCurrentUserRepositories(
              page: 1,
              perPage: 30,
              type: filter.rawValue,
              sort: sort.rawValue
            )
            await send(.repositoriesResponse(.success(repositories)))
          } catch {
            await send(.repositoriesResponse(.failure(error)))
          }
        }
        
      case .searchQueryChanged(let query):
        state.searchQuery = query
        if query.isEmpty {
          return .send(.searchCancelled)
        }
        return .none
        
      case .searchSubmitted:
        guard !state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          return .none
        }
        
        state.isSearching = true
        state.errorMessage = nil
        
        return .run { [query = state.searchQuery] send in
          do {
            let repositories = try await gitHubClient.searchUserRepositories(query: query)
            await send(.searchResponse(.success(repositories)))
          } catch {
            await send(.searchResponse(.failure(error)))
          }
        }
        
      case .searchCancelled:
        state.searchQuery = ""
        state.isSearching = false
        state.isShowingSearchResults = false
        state.searchResults = []
        return .none
        
      case .searchResponse(.success(let repositories)):
        state.isSearching = false
        state.searchResults = repositories
        state.isShowingSearchResults = true
        return .none
        
      case .searchResponse(.failure(let error)):
        Self.handleError(&state, error: error, loadingKeyPath: \.isSearching, errorKeyPath: \.errorMessage)
        return .none
        
      case .filterChanged(let filter):
        state.selectedFilter = filter
        state.isShowingSearchResults = false
        state.searchQuery = ""
        return .send(.refresh)
        
      case .sortChanged(let sort):
        state.selectedSort = sort
        state.isShowingSearchResults = false
        state.searchQuery = ""
        return .send(.refresh)
        
      case .repositoryTapped(let repository):
        return .run { _ in
          await navigation.goToRepositoryDetail(repository)
        }
        
      case .loadMore:
        guard state.hasMore && !state.isLoadingMore else {
          return .none
        }
        
        state.isLoadingMore = true
        let nextPage = state.currentPage + 1
        
        return .run { [filter = state.selectedFilter, sort = state.selectedSort] send in
          do {
            let repositories = try await gitHubClient.getCurrentUserRepositories(
              page: nextPage,
              perPage: 30,
              type: filter.rawValue,
              sort: sort.rawValue
            )
            await send(.loadMoreResponse(.success(repositories)))
          } catch {
            await send(.loadMoreResponse(.failure(error)))
          }
        }
        
      case .loadMoreResponse(.success(let newRepositories)):
        state.isLoadingMore = false
        state.currentPage += 1
        
        if newRepositories.count < 30 {
          state.hasMore = false
        }
        
        state.repositories.append(contentsOf: newRepositories)
        return .none
        
      case .loadMoreResponse(.failure(let error)):
        Self.handlePaginationError(&state, error: error)
        return .none
        
      case .repositoriesResponse(.success(let repositories)):
        state.isLoading = false
        state.repositories = repositories
        
        if repositories.count < 30 {
          state.hasMore = false
        }
        
        return .none
        
      case .repositoriesResponse(.failure(let error)):
        Self.handleError(&state, error: error)
        return .none
      }
    }
  }
}

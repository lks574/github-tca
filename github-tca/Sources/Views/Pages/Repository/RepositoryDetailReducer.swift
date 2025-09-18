import ComposableArchitecture
import SwiftUI

@Reducer
struct RepositoryDetailReducer {
  @Dependency(\.gitHubClient) var gitHubClient
  @Dependency(\.gitHubAuthClient) var gitHubAuthClient
  
  @ObservableState
  struct State: Equatable {
    var repository: ProfileModel.RepositoryItem
    var isLoading = false
    var errorMessage: String?
    
    // README 관련 상태
    var readmeContent: String?
    var isLoadingReadme = false
    var readmeError: String?
    
    // 액션 상태
    var isStarred = false
    var isWatching = false
    var isForkable = true
    
    init(repository: ProfileModel.RepositoryItem) {
      self.repository = repository
    }
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    case refreshRepository
    case loadReadme
    case readmeLoaded(Result<String, Error>)
    
    // 리포지토리 액션들
    case starTapped
    case starResponse(Result<Void, Error>)
    case watchTapped
    case watchResponse(Result<Void, Error>)
    case forkTapped
    case forkResponse(Result<GitHubRepository, Error>)
    case shareTapped
    case openInBrowser
    case copyURL
    
    // 네비게이션 액션들
    case issuesTapped
    case pullRequestsTapped
    case contributorsTapped
    case branchesTapped
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        return .send(.loadReadme)
        
      case .refreshRepository:
        state.isLoading = true
        state.errorMessage = nil
        return .run { [repository = state.repository] send in
          try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 딜레이
          await send(.binding(.set(\.isLoading, false)))
        }
        
      case .loadReadme:
        state.isLoadingReadme = true
        state.readmeError = nil
        return .run { [repository = state.repository] send in
          await send(.readmeLoaded(
            Result {
              // 실제 구현에서는 GitHub API로 README 가져오기
              try await Task.sleep(nanoseconds: 1_500_000_000)
              return """
              # \(repository.name)
              
              \(repository.description ?? "이 리포지토리에 대한 설명이 없습니다.")
              
              ## 설치
              
              ```bash
              git clone https://github.com/\(repository.fullName).git
              cd \(repository.name)
              ```
              
              ## 사용법
              
              이 프로젝트는 \(repository.language ?? "다양한 언어")로 작성되었습니다.
              
              ## 기여하기
              
              Issues와 Pull Requests를 환영합니다!
              
              ## 라이선스
              
              이 프로젝트는 오픈소스 라이선스를 따릅니다.
              """
            }
          ))
        }
        
      case let .readmeLoaded(.success(content)):
        state.isLoadingReadme = false
        state.readmeContent = content
        return .none
        
      case let .readmeLoaded(.failure(error)):
        state.isLoadingReadme = false
        state.readmeError = "README를 불러올 수 없습니다: \(error.localizedDescription)"
        return .none
        
      case .starTapped:
        state.isStarred.toggle()
        let isStarred = state.isStarred
        return .run { [repository = state.repository] send in
          await send(.starResponse(
            Result {
              try await Task.sleep(nanoseconds: 500_000_000)
              print("\(repository.name) \(isStarred ? "스타 추가" : "스타 제거")")
            }
          ))
        }
        
      case .starResponse(.success):
        return .none
        
      case let .starResponse(.failure(error)):
        state.isStarred.toggle() // 실패 시 되돌리기
        state.errorMessage = "스타 처리 실패: \(error.localizedDescription)"
        return .none
        
      case .watchTapped:
        state.isWatching.toggle()
        let isWatching = state.isWatching
        return .run { [repository = state.repository] send in
          await send(.watchResponse(
            Result {
              try await Task.sleep(nanoseconds: 500_000_000)
              print("\(repository.name) \(isWatching ? "구독 시작" : "구독 취소")")
            }
          ))
        }
        
      case .watchResponse(.success):
        return .none
        
      case let .watchResponse(.failure(error)):
        state.isWatching.toggle() // 실패 시 되돌리기
        state.errorMessage = "구독 처리 실패: \(error.localizedDescription)"
        return .none
        
      case .forkTapped:
        return .run { [repository = state.repository] send in
          await send(.forkResponse(
            Result {
              try await Task.sleep(nanoseconds: 1_000_000_000)
              print("\(repository.name) 포크 생성")
              // 실제로는 포크된 리포지토리 정보를 반환
              throw NSError(domain: "NotImplemented", code: 0, userInfo: [NSLocalizedDescriptionKey: "포크 기능은 아직 구현되지 않았습니다."])
            }
          ))
        }
        
      case .forkResponse(.success):
        return .none
        
      case let .forkResponse(.failure(error)):
        state.errorMessage = "포크 실패: \(error.localizedDescription)"
        return .none
        
      case .shareTapped:
        print("공유 시트 표시")
        return .none
        
      case .openInBrowser:
        if let url = URL(string: "https://github.com/\(state.repository.fullName)") {
          print("브라우저에서 열기: \(url)")
        }
        return .none
        
      case .copyURL:
        print("URL 복사됨: https://github.com/\(state.repository.fullName)")
        return .none
        
      case .issuesTapped:
        print("Issues 화면으로 이동")
        return .none
        
      case .pullRequestsTapped:
        print("Pull Requests 화면으로 이동")
        return .none
        
      case .contributorsTapped:
        print("Contributors 화면으로 이동")
        return .none
        
      case .branchesTapped:
        print("Branches 화면으로 이동")
        return .none
      }
    }
  }
}

import ComposableArchitecture
import SwiftUI

@Reducer
struct RepositoryDetailReducer {
  @Dependency(\.gitHubClient) var gitHubClient
  @Dependency(\.gitHubAuthClient) var gitHubAuthClient
  
  @ObservableState
  struct State: Equatable, ErrorHandlingState {
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
    
    // 리포지토리 액션들
    case starTapped
    case watchTapped
    case forkTapped
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
        Self.startLoading(&state)
        return .run { [repository = state.repository, gitHubClient] send in
          do {
            // fullName에서 owner/repo 분리 (예: "lks574/ios_practice" -> owner: "lks574", repo: "ios_practice")
            let components = repository.fullName.split(separator: "/")
            guard components.count == 2 else {
              throw GitHubError.invalidQuery
            }
            
            let owner = String(components[0])
            let repo = String(components[1])
            
            // 리포지토리 상세 정보 다시 불러오기
            let freshRepository = try await gitHubClient.getRepository(
              owner: owner,
              repo: repo
            )
            
            await send(.binding(.set(\.isLoading, false)))
            await send(.binding(.set(\.errorMessage, nil)))
            
            // 기존 RepositoryItem을 새로운 데이터로 업데이트
            await send(.binding(.set(\.repository, freshRepository.toProfileRepositoryItem())))
            
            // README도 다시 로드
            await send(.loadReadme)
          } catch {
            await send(.binding(.set(\.isLoading, false)))
            
            // GitHubError 우선 처리
            let errorMessage: String
            if let gitHubError = error as? GitHubError {
              errorMessage = gitHubError.localizedDescription
              print("❌ GitHubError: \(gitHubError.localizedDescription)")
            } else {
              errorMessage = error.localizedDescription
              print("❌ 일반 에러: \(error.localizedDescription)")
            }
            
            await send(.binding(.set(\.errorMessage, errorMessage)))
          }
        }
        
      case .loadReadme:
        state.isLoadingReadme = true
        state.readmeError = nil
        return .run { [repository = state.repository] send in
          do {
            // 실제 GitHub API로 README 가져오기 (임시로 Mock 데이터 사용)
            try await Task.sleep(nanoseconds: 1_500_000_000)
            let content = """
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
            
            await send(.binding(.set(\.isLoadingReadme, false)))
            await send(.binding(.set(\.readmeContent, content)))
          } catch {
            await send(.binding(.set(\.isLoadingReadme, false)))
            await send(.binding(.set(\.readmeError, "README를 불러올 수 없습니다: \(error.localizedDescription)")))
          }
        }
        
      case .starTapped:
        state.isStarred.toggle()
        let isStarred = state.isStarred
        return .run { [repository = state.repository] send in
          do {
            try await Task.sleep(nanoseconds: 500_000_000)
            print("\(repository.name) \(isStarred ? "스타 추가" : "스타 제거")")
            // 성공 시 추가 작업 없음
          } catch {
            // 실패 시 상태 되돌리기
            await send(.binding(.set(\.isStarred, !isStarred)))
            
            // GitHubError 우선 처리
            let errorMessage: String
            if let gitHubError = error as? GitHubError {
              errorMessage = gitHubError.localizedDescription
              print("❌ 스타 처리 GitHubError: \(gitHubError.localizedDescription)")
            } else {
              errorMessage = error.localizedDescription
              print("❌ 스타 처리 일반 에러: \(error.localizedDescription)")
            }
            
            await send(.binding(.set(\.errorMessage, errorMessage)))
          }
        }
        
      case .watchTapped:
        state.isWatching.toggle()
        let isWatching = state.isWatching
        return .run { [repository = state.repository] send in
          do {
            try await Task.sleep(nanoseconds: 500_000_000)
            print("\(repository.name) \(isWatching ? "구독 시작" : "구독 취소")")
            // 성공 시 추가 작업 없음
          } catch {
            // 실패 시 상태 되돌리기
            await send(.binding(.set(\.isWatching, !isWatching)))
            
            // GitHubError 우선 처리
            let errorMessage: String
            if let gitHubError = error as? GitHubError {
              errorMessage = gitHubError.localizedDescription
              print("❌ 구독 처리 GitHubError: \(gitHubError.localizedDescription)")
            } else {
              errorMessage = error.localizedDescription
              print("❌ 구독 처리 일반 에러: \(error.localizedDescription)")
            }
            
            await send(.binding(.set(\.errorMessage, errorMessage)))
          }
        }
        
      case .forkTapped:
        return .run { [repository = state.repository] send in
          do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("\(repository.name) 포크 생성")
            // 실제로는 포크된 리포지토리 정보를 반환
            throw NSError(domain: "NotImplemented", code: 0, userInfo: [NSLocalizedDescriptionKey: "포크 기능은 아직 구현되지 않았습니다."])
          } catch {
            // GitHubError 우선 처리
            let errorMessage: String
            if let gitHubError = error as? GitHubError {
              errorMessage = gitHubError.localizedDescription
              print("❌ 포크 처리 GitHubError: \(gitHubError.localizedDescription)")
            } else {
              errorMessage = error.localizedDescription
              print("❌ 포크 처리 일반 에러: \(error.localizedDescription)")
            }
            
            await send(.binding(.set(\.errorMessage, errorMessage)))
          }
        }
        
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

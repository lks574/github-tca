import ComposableArchitecture

@Reducer
struct AppReducer {

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    @Presents var present: Present.State?
    var selectedTab: GitHubTabBar.GitHubTab = .home
    
    // 인증 상태
    var isAuthenticated = false
    var currentUser: GitHubUser?
    var isCheckingAuthentication = false
  }

  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case present(PresentationAction<Present.Action>)
    case goToHome
    case goToSettings
    case tabSelected(GitHubTabBar.GitHubTab)
    
    // 인증 관련 액션
    case checkStoredAuthentication
    case authenticationRestored(GitHubAuthResult)
    case authenticationFailed
    case signOut
  }

  @Reducer(state: .equatable)
  enum Present {

  }

  @Dependency(\.gitHubAuthClient) var gitHubAuthClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .goToHome:
        state.path.append(.home(.init()))
        return .none
        
      case .goToSettings:
        state.path.append(.settings(.init()))
        return .none
        
      case let .tabSelected(tab):
        state.selectedTab = tab
        
        // 탭 변경 시 기존 스택만 초기화 (첫 화면은 root에서 표시)
        state.path = StackState()
        return .none
        
      // 인증 관련 액션들
      case .checkStoredAuthentication:
        state.isCheckingAuthentication = true
        return .run { send in
          do {
            if let authResult = try await gitHubAuthClient.restoreAuthentication() {
              await send(.authenticationRestored(authResult))
            } else {
              await send(.authenticationFailed)
            }
          } catch {
            print("❌ 저장된 인증 복원 실패: \(error)")
            await send(.authenticationFailed)
          }
        }
        
      case let .authenticationRestored(authResult):
        state.isCheckingAuthentication = false
        state.isAuthenticated = true
        state.currentUser = authResult.user
        print("✅ 자동 로그인 성공: \(authResult.user.login)")
        return .none
        
      case .authenticationFailed:
        state.isCheckingAuthentication = false
        state.isAuthenticated = false
        state.currentUser = nil
        return .none
        
      case .signOut:
        state.isAuthenticated = false
        state.currentUser = nil
        return .run { _ in
          try await gitHubAuthClient.signOut()
          print("✅ 로그아웃 완료")
        }
        
      case .path, .present:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$present, action: \.present)
  }
}

extension StackState where Element == Path.State {
  fileprivate mutating func popOrPush(_ new: Element) {
    if let i = self.lastIndex(where: { $0.caseID == new.caseID }) {
      self.removeSubrange(index(after: i)..<endIndex)
    } else {
      self.append(new)
    }
  }
}

@CasePathable
@Reducer(state: .equatable)
enum Path {
  case home(HomeReducer)
  case notifications(NotificationsReducer)
  case explore(ExploreReducer)
  case profile(ProfileReducer)
  case settings(SettingsReducer)
}

extension Path.State {
  fileprivate var caseID: String {
    switch self {
    case .home: "home"
    case .notifications: "notifications"
    case .explore: "explore"
    case .profile: "profile"
    case .settings: "settings"
    }
  }
}

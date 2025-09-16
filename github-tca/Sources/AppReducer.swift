import ComposableArchitecture

@Reducer
struct AppReducer {

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    @Presents var present: Present.State?
    var selectedTab: GitHubTab = .home
  }

  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case present(PresentationAction<Present.Action>)
    case goToHome
    case tabSelected(GitHubTab)
  }

  @Reducer(state: .equatable)
  enum Present {

  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .goToHome:
        state.path.append(.home(.init()))
        return .none
        
      case let .tabSelected(tab):
        state.selectedTab = tab
        
        // 탭 변경 시 기존 스택 초기화하고 새로운 화면으로
        state.path = StackState()
        switch tab {
        case .home:
          state.path.append(.home(.init()))
        case .notifications:
          state.path.append(.notifications(.init()))
        case .explore:
          state.path.append(.explore(.init()))
        case .profile:
          state.path.append(.profile(.init()))
        }
        return .none
        
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
}

extension Path.State {
  fileprivate var caseID: String {
    switch self {
    case .home: "home"
    case .notifications: "notifications"
    case .explore: "explore"
    case .profile: "profile"
    }
  }
}

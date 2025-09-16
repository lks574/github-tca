import ComposableArchitecture

@Reducer
struct AppReducer {

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    @Presents var present: Present.State?
  }

  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case present(PresentationAction<Present.Action>)
    case goToHome
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
}

extension Path.State {
  fileprivate var caseID: String {
    switch self {
      case .home: "home"
    }
  }
}

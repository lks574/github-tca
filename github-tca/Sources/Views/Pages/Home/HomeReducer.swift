import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeReducer {
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
      }
    }
  }
}

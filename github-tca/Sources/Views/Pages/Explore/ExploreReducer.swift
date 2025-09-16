import ComposableArchitecture
import SwiftUI

@Reducer
struct ExploreReducer {
  @ObservableState
  struct State: Equatable {
    var searchItems: [ExploreModel.SearchItem] = .default
    var popularRepositories: [ExploreModel.PopularRepository] = .default
    var activityItems: [ExploreModel.ActivityItem] = .default
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case searchItemTapped(ExploreModel.SearchItem)
    case repositoryTapped(ExploreModel.PopularRepository)
    case activityItemTapped(ExploreModel.ActivityItem)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .searchItemTapped(item):
        return .run { _ in
          print("\(item.title) 검색 아이템 선택됨")
        }
        
      case let .repositoryTapped(repository):
        return .run { _ in
          print("\(repository.fullName) 리포지토리 선택됨")
        }
        
      case let .activityItemTapped(activity):
        return .run { _ in
          print("\(activity.fullName) 활동 아이템 선택됨")
        }
      }
    }
  }
}

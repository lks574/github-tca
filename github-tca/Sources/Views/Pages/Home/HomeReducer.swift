import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeReducer {
  @Dependency(\.navigation) var navigation

  @ObservableState
  struct State: Equatable {
    var searchText = ""
    var isLoading = false
    var menuItems: [HomeMenuItem] = .defulat
    var starredRepositories: [HomeMenuItem] = []
    var quickAccessItems: [QuickAccessItem] = .default
    var recentItems: [RecentItem] = .default
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case loadMoreItems
    case menuItemTapped(HomeMenuItem.MenuType)
    case addBookmarkTapped
    case quickAccessTapped
    case recentItemTapped(RecentItem)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .loadMoreItems:
        state.isLoading = true
        return .run { send in
        }

      case let .menuItemTapped(menuType):
        return .run { _ in
          // 메뉴 아이템 탭 처리 시뮬레이션
          try await Task.sleep(nanoseconds: 500_000_000)
          print("\(menuType.rawValue) 화면으로 이동")
        }

      case .addBookmarkTapped:
        return .none

      case .quickAccessTapped:
        return .none

      case .recentItemTapped:
        return .none
      }
    }
  }
}

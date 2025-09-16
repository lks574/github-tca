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
  }

  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case loadMoreItems
    case menuItemTapped(HomeMenuItem.MenuType)
    case loadMoreItemsResponse
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
          // 더보기 데이터 로드 시뮬레이션
          try await Task.sleep(nanoseconds: 1_000_000_000)
          await send(.loadMoreItemsResponse)
        }
        
      case .loadMoreItemsResponse:
        state.isLoading = false
        return .none
        
      case let .menuItemTapped(menuType):
        return .run { _ in
          // 메뉴 아이템 탭 처리 시뮬레이션
          try await Task.sleep(nanoseconds: 500_000_000)
          print("\(menuType.rawValue) 화면으로 이동")
        }
      }
    }
  }
}

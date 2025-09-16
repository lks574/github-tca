import SwiftUI
import ComposableArchitecture

struct AppView: View {
  @Bindable var store: StoreOf<AppReducer>

  var body: some View {
    VStack(spacing: 0) {
      // 메인 콘텐츠
      NavigationStack(
        path: $store.scope(state: \.path, action: \.path),
        root: {
          // 홈 화면을 기본으로 표시
          if store.path.isEmpty {
            HomePage.RootView(store: Store(initialState: HomeReducer.State()) {
              HomeReducer()
            })
          } else {
            EmptyView()
          }
        },
        destination: { store in
          switch store.case {
          case .home(let store):
            HomePage.RootView(store: store)
          case .notifications(let store):
            NotificationsPage.RootView(store: store)
          case .explore(let store):
            ExplorePage.RootView(store: store)
          case .profile:
            ProfilePage.RootView()
          }
        }
      )
      
      // 하단 탭바
      GitHubTabBar(selectedTab: $store.selectedTab.sending(\.tabSelected))
    }
    .sheet(
      store: store.scope(state: \.$present, action: \.present))
    { _ in
      EmptyView()
    }
    .onAppear {
      // 앱 시작 시 홈 화면으로 이동
      if store.path.isEmpty {
        store.send(.goToHome)
      }
    }
  }
}

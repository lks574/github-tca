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
          // 현재 선택된 탭의 첫 화면을 root로 표시
          switch store.selectedTab {
          case .home:
            HomePage.RootView(store: Store(initialState: HomeReducer.State()) {
              HomeReducer()
            })
          case .notifications:
            NotificationsPage.RootView(store: Store(initialState: NotificationsReducer.State()) {
              NotificationsReducer()
            })
          case .explore:
            ExplorePage.RootView(store: Store(initialState: ExploreReducer.State()) {
              ExploreReducer()
            })
          case .profile:
            ProfilePage.RootView(store: Store(initialState: ProfileReducer.State()) {
              ProfileReducer()
            })
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
          case .profile(let store):
            ProfilePage.RootView(store: store)
          case .settings(let store):
            SettingsPage.RootView(store: store)
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
      // 첫 화면은 이미 root에서 표시됨
    }
  }
}

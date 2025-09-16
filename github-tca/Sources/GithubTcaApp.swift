import SwiftUI
import ComposableArchitecture

@main
struct GithubTcaApp: App {
  
  @State private var store: StoreOf<AppReducer>
  
  init() {
    let store = Store(initialState: AppReducer.State()) {
      AppReducer()
    }
    self._store = State(initialValue: store)
  }
  
  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .onAppear {
          setupNavigationDependency()
        }
    }
  }
  
  private func setupNavigationDependency() {
    NavigationClient.liveValue = NavigationClient(
      goToHome: { [store] in
        await store.send(.goToHome)
      }
    )
  }
}

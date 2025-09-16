import SwiftUI
import ComposableArchitecture

struct AppView: View {

  @Bindable var store: StoreOf<AppReducer>

  var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path),
      root: {
        VStack(spacing: 8) {
          Text("시작")
            .font(.headline)
          Button(action: { store.send(.goToHome) })
          {
            Text("HomePage 이동")
          }

          Divider()
        }
      },
      destination: { store in
        switch store.case {
        case .home(let store):
          HomePage.RootView(store: store)
        }
      }
    )
    .sheet(
      store: store.scope(state: \.$present, action: \.present))
    { _ in

    }
  }
}

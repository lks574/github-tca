import SwiftUI
import ComposableArchitecture

@main
struct GithubTcaApp: App {
  
  @State private var store: StoreOf<AppReducer>
  @State private var isNetworkLoggerPresented = false
  
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
          // 앱 시작 시 저장된 인증 정보 복원 시도
          store.send(.checkStoredAuthentication)
        }
        .onOpenURL { url in
          handleIncomingURL(url)
        }
        .onShake {
          // 기기 흔들기로 커스텀 네트워크 디버거 표시
          isNetworkLoggerPresented = true
        }
        .sheet(isPresented: $isNetworkLoggerPresented) {
          NetworkLoggerView()
        }
    }
  }
  
  private func setupNavigationDependency() {
    NavigationClient.liveValue = NavigationClient(
      goToHome: { [store] in
        await store.send(.goToHome)
      },
      goToSettings: { [store] in
        await store.send(.goToSettings)
      },
      goToRepositoryDetail: { [store] repository in
        await store.send(.goToRepositoryDetail(repository))
      },
      goToRepositoryList: { [store] in
        await store.send(.goToRepositoryList)
      },
      goToNotificationDetail: { [store] notification in
        await store.send(.goToNotificationDetail(notification))
      },
      signOut: { [store] in
        await store.send(.signOut)
      }
    )
  }
  
  private func handleIncomingURL(_ url: URL) {
    // GitHub OAuth 콜백 URL 처리
    guard url.scheme == "github-tca",
          url.host == "oauth" else {
      print("⚠️ 지원하지 않는 URL 스키마: \(url)")
      return
    }
    
    print("✅ GitHub OAuth 콜백 URL 수신: \(url)")
    // 실제로는 OAuth 플로우를 완료하는 로직이 ASWebAuthenticationSession에서 처리됨
  }
}

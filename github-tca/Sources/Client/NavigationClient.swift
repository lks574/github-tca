import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToHome: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToHome: { }
  )

  static let testValue = NavigationClient(
    goToHome: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}

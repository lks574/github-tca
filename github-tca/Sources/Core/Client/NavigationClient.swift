import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToHome: @Sendable () async -> Void
  var goToSettings: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToHome: { },
    goToSettings: { }
  )

  static let testValue = NavigationClient(
    goToHome: { },
    goToSettings: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}

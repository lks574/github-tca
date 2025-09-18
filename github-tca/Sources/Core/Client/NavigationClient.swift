import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToHome: @Sendable () async -> Void
  var goToSettings: @Sendable () async -> Void
  var signOut: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToHome: { },
    goToSettings: { },
    signOut: { }
  )

  static let testValue = NavigationClient(
    goToHome: { },
    goToSettings: { },
    signOut: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}

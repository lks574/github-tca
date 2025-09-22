import SwiftUI
import ComposableArchitecture

struct NavigationClient {
  var goToHome: @Sendable () async -> Void
  var goToSettings: @Sendable () async -> Void
  var goToRepositoryDetail: @Sendable (ProfileModel.RepositoryItem) async -> Void
  var goToRepositoryList: @Sendable () async -> Void
  var goToNotificationDetail: @Sendable (NotificationsModel.NotificationItem) async -> Void
  var signOut: @Sendable () async -> Void
}

extension NavigationClient: DependencyKey {
  static var liveValue = NavigationClient(
    goToHome: { },
    goToSettings: { },
    goToRepositoryDetail: { _ in },
    goToRepositoryList: { },
    goToNotificationDetail: { _ in },
    signOut: { }
  )

  static let testValue = NavigationClient(
    goToHome: { },
    goToSettings: { },
    goToRepositoryDetail: { _ in },
    goToRepositoryList: { },
    goToNotificationDetail: { _ in },
    signOut: { }
  )
}

extension DependencyValues {
  var navigation: NavigationClient {
    get { self[NavigationClient.self] }
    set { self[NavigationClient.self] = newValue }
  }
}

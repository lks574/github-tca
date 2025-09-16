import SwiftUI
import Foundation

enum NotificationsModel {
  
  // MARK: - Notification Item Model
  struct NotificationItem: Equatable, Identifiable {
    let id = UUID()
    let repository: String
    let title: String
    let subtitle: String
    let type: NotificationType
    let timeAgo: String
    let isUnread: Bool
    let avatar: String?
    
    enum NotificationType {
      case issue
      case pullRequest
      case commit
      case release
      case mention
      case review
      case discussion
      
      var icon: String {
        switch self {
        case .issue:
          return "exclamationmark.circle.fill"
        case .pullRequest:
          return "arrow.triangle.merge"
        case .commit:
          return "circle.fill"
        case .release:
          return "tag.fill"
        case .mention:
          return "at"
        case .review:
          return "eye.fill"
        case .discussion:
          return "bubble.left.and.bubble.right.fill"
        }
      }
      
      var iconColor: Color {
        switch self {
        case .issue:
          return .githubGreen
        case .pullRequest:
          return .githubBlue
        case .commit:
          return .githubSecondaryText
        case .release:
          return .githubOrange
        case .mention:
          return .githubPurple
        case .review:
          return .githubBlue
        case .discussion:
          return .githubPurple
        }
      }
    }
  }
  
  // MARK: - Filter Type
  enum FilterType: String, CaseIterable {
    case all = "all"
    case unread = "unread"
    case participating = "participating"
    
    var title: String {
      switch self {
      case .all:
        return "모든 알림"
      case .unread:
        return "읽지 않음"
      case .participating:
        return "참여 중"
      }
    }
  }
  
  // MARK: - Repository Filter
  struct RepositoryFilter: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let count: Int
  }
}

// MARK: - Extensions for Default Data
extension [NotificationsModel.NotificationItem] {
  static let `default`: Self = [
    .init(
      repository: "flitto/qr_place_android",
      title: "chore(deps): bump androidx.datastore:datastore-preferences from 1.0.0 to 1.1.7",
      subtitle: "#939",
      type: .pullRequest,
      timeAgo: "13시간",
      isUnread: true,
      avatar: "🔄"
    ),
    .init(
      repository: "flitto/flitto_android_v2",
      title: "[CI-1730] 이미지변역 api 연결 작업 - 1차",
      subtitle: "## 작업명",
      type: .issue,
      timeAgo: "1일",
      isUnread: true,
      avatar: "📝"
    ),
    .init(
      repository: "flitto/flitto_android_v2",
      title: "Version v25.9.12 for Global",
      subtitle: "## Changes",
      type: .release,
      timeAgo: "1일",
      isUnread: false,
      avatar: "🏷️"
    ),
    .init(
      repository: "flitto/flitto_android_v2",
      title: "sync: Global 독기화",
      subtitle: "@kyungseoklee mentioned you in a comment",
      type: .mention,
      timeAgo: "2일",
      isUnread: false,
      avatar: "💬"
    )
  ]
}

extension [NotificationsModel.RepositoryFilter] {
  static let `default`: Self = [
    .init(name: "flitto/qr_place_android", count: 1),
    .init(name: "flitto/flitto_android_v2", count: 3),
    .init(name: "flitto/translation_service", count: 2)
  ]
}

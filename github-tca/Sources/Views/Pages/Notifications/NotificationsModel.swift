import SwiftUI
import Foundation

enum NotificationsModel {
  
  // MARK: - Notification Item Model
  struct NotificationItem: Equatable, Identifiable {
    let id: String
    let repository: String
    let title: String
    let subtitle: String
    let type: NotificationType
    let timeAgo: String
    let isUnread: Bool
    let avatar: String
    let reason: String
    let url: String?
    let issueNumber: String? // PR이나 Issue 번호 (#942 등)
    
    enum NotificationType: String {
      case issue = "Issue"
      case pullRequest = "PullRequest"
      case commit = "Commit"
      case release = "Release"
      case checkSuite = "CheckSuite"
      case discussion = "Discussion"
      case repositoryVulnerabilityAlert = "RepositoryVulnerabilityAlert"
      case unknown
      
      init(from string: String) {
        self = NotificationType(rawValue: string) ?? .unknown
      }
      
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
        case .checkSuite:
          return "checkmark.circle.fill"
        case .discussion:
          return "bubble.left.and.bubble.right.fill"
        case .repositoryVulnerabilityAlert:
          return "exclamationmark.triangle.fill"
        case .unknown:
          return "bell.fill"
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
        case .checkSuite:
          return .githubGreen
        case .discussion:
          return .githubPurple
        case .repositoryVulnerabilityAlert:
          return .githubRed
        case .unknown:
          return .githubSecondaryText
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
      id: "1",
      repository: "flitto/qr_place_android",
      title: "sync: Global 동기화",
      subtitle: "## 작업명",
      type: .pullRequest,
      timeAgo: "34분",
      isUnread: true,
      avatar: "🔄",
      reason: "subscribed",
      url: "https://github.com/flitto/qr_place_android/pull/942",
      issueNumber: "#942"
    ),
    .init(
      id: "2",
      repository: "flitto/flitto_android_v2",
      title: "Version v25.9.18 for Global",
      subtitle: "## Changes",
      type: .release,
      timeAgo: "3일",
      isUnread: true,
      avatar: "🏷️",
      reason: "subscribed",
      url: "https://github.com/flitto/flitto_android_v2/releases/tag/v25.9.18",
      issueNumber: nil
    ),
    .init(
      id: "3",
      repository: "flitto/qr_place_android",
      title: "chore(deps): bump com.android.application from 7.4.0 to 8.13.0",
      subtitle: "Bumps com.android.application from...",
      type: .pullRequest,
      timeAgo: "3일",
      isUnread: true,
      avatar: "🔄",
      reason: "subscribed",
      url: "https://github.com/flitto/qr_place_android/pull/938",
      issueNumber: "#938"
    ),
    .init(
      id: "4",
      repository: "flitto/qr_place_android",
      title: "[QA-16472] epic: Android15 대응",
      subtitle: "## 작업명",
      type: .issue,
      timeAgo: "3일",
      isUnread: true,
      avatar: "🔴",
      reason: "subscribed",
      url: "https://github.com/flitto/qr_place_android/issues/941",
      issueNumber: "#941"
    ),
    .init(
      id: "5",
      repository: "flitto/qr_place_android",
      title: "[QA-16472] 메뉴번역 android15 - qa 대응 (edgeToedge 비활성화 처리)",
      subtitle: "## 작업명",
      type: .issue,
      timeAgo: "3일",
      isUnread: true,
      avatar: "🔴",
      reason: "subscribed",
      url: "https://github.com/flitto/qr_place_android/issues/940",
      issueNumber: "#940"
    ),
    .init(
      id: "6",
      repository: "flitto/flitto_android_v2",
      title: "sync: Global 동기화",
      subtitle: "## 작업명",
      type: .pullRequest,
      timeAgo: "4일",
      isUnread: false,
      avatar: "🔄",
      reason: "subscribed",
      url: "https://github.com/flitto/flitto_android_v2/pull/1596",
      issueNumber: "#1596"
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

// MARK: - GitHubNotification Extension
extension GitHubNotification {
  func toNotificationItem() -> NotificationsModel.NotificationItem {
    let type = NotificationsModel.NotificationItem.NotificationType(from: subject.type)
    
    // GitHub에서 제공하는 reason에 따른 subtitle 생성
    let subtitle: String = {
      switch reason {
      case "mention":
        return "당신이 언급되었습니다"
      case "assign":
        return "당신이 할당되었습니다"
      case "review_requested":
        return "리뷰가 요청되었습니다"
      case "author":
        return "당신이 작성자입니다"
      case "subscribed":
        return "구독 중인 알림"
      case "team_mention":
        return "팀이 언급되었습니다"
      case "comment":
        return "새로운 댓글"
      case "state_change":
        return "상태가 변경되었습니다"
      default:
        return reason.capitalized
      }
    }()
    
    // 시간 포맷팅
    let timeAgo = formatTimeAgo(from: updatedAt)
    
    // 아바타 이모지 (타입에 따라)
    let avatar: String = {
      switch type {
      case .issue: return "🐛"
      case .pullRequest: return "🔄"
      case .commit: return "📝"
      case .release: return "🏷️"
      case .checkSuite: return "✅"
      case .discussion: return "💬"
      case .repositoryVulnerabilityAlert: return "⚠️"
      case .unknown: return "🔔"
      }
    }()
    
    // Issue/PR 번호 추출
    let issueNumber: String? = {
      if let subjectUrl = subject.url {
        // URL에서 이슈/PR 번호 추출: "https://api.github.com/repos/owner/repo/issues/123"
        let components = subjectUrl.components(separatedBy: "/")
        if let lastComponent = components.last, let number = Int(lastComponent) {
          return "#\(number)"
        }
      }
      return nil
    }()
    
    return NotificationsModel.NotificationItem(
      id: id,
      repository: repository.fullName,
      title: subject.title,
      subtitle: subtitle,
      type: type,
      timeAgo: timeAgo,
      isUnread: unread,
      avatar: avatar,
      reason: reason,
      url: subject.url,
      issueNumber: issueNumber
    )
  }
  
  private func formatTimeAgo(from dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: dateString) else {
      return "알 수 없음"
    }
    
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.dateTimeStyle = .named
    return relativeFormatter.localizedString(for: date, relativeTo: Date())
  }
}

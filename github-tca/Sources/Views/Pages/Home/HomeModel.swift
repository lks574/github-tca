import SwiftUI

// MARK: - Home Menu Item Model
struct HomeMenuItem: Equatable, Identifiable {
  let id = UUID()
  let icon: String
  let iconColor: Color
  let title: String
  let type: MenuType

  enum MenuType: String, CaseIterable {
    case issues = "issues"
    case pullRequests = "pullRequests"
    case discussions = "discussions"
    case projects = "projects"
    case repositories = "repositories"
    case organizations = "organizations"
    case starred = "starred"
  }
}

extension [HomeMenuItem] {
  static let `defulat`: [HomeMenuItem] = [
    HomeMenuItem(
      icon: "exclamationmark.circle.fill",
      iconColor: .githubGreen,
      title: "Issue",
      type: .issues
    ),
    HomeMenuItem(
      icon: "arrow.triangle.merge",
      iconColor: .githubBlue,
      title: "Pull Request",
      type: .pullRequests
    ),
    HomeMenuItem(
      icon: "bubble.left.and.bubble.right.fill",
      iconColor: .githubPurple,
      title: "Discussions",
      type: .discussions
    ),
    HomeMenuItem(
      icon: "folder.fill",
      iconColor: .githubSecondaryText,
      title: "프로젝트",
      type: .projects
    ),
    HomeMenuItem(
      icon: "building.2.fill",
      iconColor: .githubSecondaryText,
      title: "상위 리포지토리",
      type: .repositories
    ),
    HomeMenuItem(
      icon: "chart.bar.fill",
      iconColor: .githubOrange,
      title: "조직",
      type: .organizations
    ),
    HomeMenuItem(
      icon: "star.fill",
      iconColor: .githubWarning,
      title: "별표 표시",
      type: .starred
    )
  ]
}

// MARK: - Quick Access Item Model
struct QuickAccessItem: Equatable, Identifiable {
  let id = UUID()
  let icon: String
  let iconColor: Color
  let title: String
  let subtitle: String
}


struct RecentItem: Equatable, Identifiable {
  let id = UUID()
  let title: String
  let subtitle: String
  let type: RecentItemType

  enum RecentItemType {
    case issue
    case pullRequest
    case repository
    case discussion
  }

  var icon: String {
    switch type {
    case .issue:
      return "exclamationmark.circle"
    case .pullRequest:
      return "arrow.triangle.merge"
    case .repository:
      return "folder"
    case .discussion:
      return "bubble.left.and.bubble.right"
    }
  }

  var iconColor: Color {
    switch type {
    case .issue:
      return .githubGreen
    case .pullRequest:
      return .githubBlue
    case .repository:
      return .githubSecondaryText
    case .discussion:
      return .githubPurple
    }
  }
}

extension [QuickAccessItem] {
  static let `default`: Self = [
    QuickAccessItem(
      icon: "bolt.fill",
      iconColor: .githubBlue,
      title: "빠른 액세스",
      subtitle: "탭 한 번에, 필요한 항목 이용 가능"
    )
  ]
}

extension [RecentItem] {
  static let `default`: Self = [
    RecentItem(
      title: "최근에 다른 Issue 및 Pull Request가 여기",
      subtitle: "표시됩니다.",
      type: .issue
    )
  ]
}

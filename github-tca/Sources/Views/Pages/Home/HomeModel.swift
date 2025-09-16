import SwiftUI

enum HomeModel {

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
}



extension [HomeModel.HomeMenuItem] {
  static let `defulat`: Self = [
    .init(
      icon: "exclamationmark.circle.fill",
      iconColor: .githubGreen,
      title: "Issue",
      type: .issues
    ),
    .init(
      icon: "arrow.triangle.merge",
      iconColor: .githubBlue,
      title: "Pull Request",
      type: .pullRequests
    ),
    .init(
      icon: "bubble.left.and.bubble.right.fill",
      iconColor: .githubPurple,
      title: "Discussions",
      type: .discussions
    ),
    .init(
      icon: "folder.fill",
      iconColor: .githubSecondaryText,
      title: "프로젝트",
      type: .projects
    ),
    .init(
      icon: "building.2.fill",
      iconColor: .githubSecondaryText,
      title: "상위 리포지토리",
      type: .repositories
    ),
    .init(
      icon: "chart.bar.fill",
      iconColor: .githubOrange,
      title: "조직",
      type: .organizations
    ),
    .init(
      icon: "star.fill",
      iconColor: .githubWarning,
      title: "별표 표시",
      type: .starred
    )
  ]
}

extension [HomeModel.QuickAccessItem] {
  static let `default`: Self = [
    .init(
      icon: "bolt.fill",
      iconColor: .githubBlue,
      title: "빠른 액세스",
      subtitle: "탭 한 번에, 필요한 항목 이용 가능"
    )
  ]
}

extension [HomeModel.RecentItem] {
  static let `default`: Self = [
    .init(
      title: "최근에 다른 Issue 및 Pull Request가 여기",
      subtitle: "표시됩니다.",
      type: .issue
    )
  ]
}

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

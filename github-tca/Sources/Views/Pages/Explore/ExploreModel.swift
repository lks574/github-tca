import SwiftUI

enum ExploreModel {

  // MARK: - Explore Models
  struct PopularRepository: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let owner: String
    let description: String
    let language: String
    let stars: Int
    let lastUpdate: String
    let isReleased: Bool

    var fullName: String {
      "\(owner)/\(name)"
    }
  }

  struct SearchItem: Equatable, Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
  }

  struct ActivityItem: Equatable, Identifiable {
    let id = UUID()
    let owner: String
    let repository: String
    let action: String
    let timeAgo: String
    let hasRelease: Bool

    var fullName: String {
      "\(owner)/\(repository)"
    }
  }

}


// MARK: - Default Data
extension [ExploreModel.SearchItem] {
  static let `default`: Self = [
    .init(
      icon: "flame.fill",
      iconColor: .githubPurple,
      title: "인기 리포지토리"
    ),
    .init(
      icon: "face.smiling.fill",
      iconColor: .githubRed,
      title: "Awesome Lists"
    )
  ]
}

extension [ExploreModel.PopularRepository] {
  static let `default`: Self = [
    .init(
      name: "swift-composable-architecture",
      owner: "pointfreeco",
      description: "A library for building applications in a consistent and understandable way",
      language: "Swift",
      stars: 11500,
      lastUpdate: "17일",
      isReleased: true
    )
  ]
}

extension [ExploreModel.ActivityItem] {
  static let `default`: Self = [
    .init(
      owner: "pointfreeco",
      repository: "swift-composable-architecture",
      action: "님이 릴리스 1개를(를) 게시함",
      timeAgo: "17일",
      hasRelease: true
    )
  ]
}

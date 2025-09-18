import SwiftUI
import Foundation

public enum ProfileModel {

  // MARK: - User Profile
  public struct UserProfile: Equatable, Identifiable {
    public let id = UUID()
    let username: String
    let displayName: String
    let bio: String?
    let avatar: String?
    let company: String?
    let location: String?
    let followerCount: Int
    let followingCount: Int
    let publicRepos: Int
    let privateRepos: Int
    let starredRepos: Int
    let organizations: Int
    let isVerified: Bool
    let joinDate: String
  }
  
  // MARK: - Profile Menu Item
  public struct ProfileMenuItem: Equatable, Identifiable {
    public let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let badgeCount: Int?
    let type: MenuType
    let hasChevron: Bool
    
    enum MenuType: String, CaseIterable {
      case repositories = "repositories"
      case starred = "starred"
      case organizations = "organizations"
      case settings = "settings"
      case notifications = "notifications"
      case security = "security"
      case billing = "billing"
      case appearance = "appearance"
      case help = "help"
      case signOut = "signOut"
    }
  }
  
  // MARK: - Repository Item
  public struct RepositoryItem: Equatable, Identifiable {
    public let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let languageColor: Color?
    let starCount: Int
    let forkCount: Int
    let isPrivate: Bool
    let updatedAt: String
  }
  
  // MARK: - Achievement
  public struct Achievement: Equatable, Identifiable {
    public let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let unlockedDate: String?
    let isUnlocked: Bool
  }
}

// MARK: - Extensions for Default Data
extension ProfileModel.UserProfile {
  static let `default`: Self = .init(
    username: "lks574",
    displayName: "KyungSeok Lee",
    bio: "상태 설정",
    avatar: nil,
    company: "flitto",
    location: nil,
    followerCount: 2,
    followingCount: 2,
    publicRepos: 22,
    privateRepos: 15,
    starredRepos: 7,
    organizations: 2,
    isVerified: true,
    joinDate: "2019년부터 GitHub 사용"
  )
}

extension [ProfileModel.ProfileMenuItem] {
  static let `default`: Self = [
    .init(
      icon: "folder.fill",
      iconColor: .githubSecondaryText,
      title: "리포지토리",
      subtitle: nil,
      badgeCount: 22,
      type: .repositories,
      hasChevron: true
    ),
    .init(
      icon: "star.fill",
      iconColor: .githubWarning,
      title: "별표 표시",
      subtitle: nil,
      badgeCount: 7,
      type: .starred,
      hasChevron: true
    ),
    .init(
      icon: "building.2.fill",
      iconColor: .githubOrange,
      title: "조직",
      subtitle: nil,
      badgeCount: 2,
      type: .organizations,
      hasChevron: true
    ),
    .init(
      icon: "gear",
      iconColor: .githubSecondaryText,
      title: "설정",
      subtitle: "계정 및 앱 설정",
      badgeCount: nil,
      type: .settings,
      hasChevron: true
    ),
    .init(
      icon: "bell.fill",
      iconColor: .githubBlue,
      title: "알림",
      subtitle: "알림 기본 설정 관리",
      badgeCount: nil,
      type: .notifications,
      hasChevron: true
    ),
    .init(
      icon: "lock.fill",
      iconColor: .githubGreen,
      title: "보안",
      subtitle: "2단계 인증, 세션",
      badgeCount: nil,
      type: .security,
      hasChevron: true
    ),
    .init(
      icon: "creditcard.fill",
      iconColor: .githubPurple,
      title: "결제",
      subtitle: "구독 및 결제 정보",
      badgeCount: nil,
      type: .billing,
      hasChevron: true
    ),
    .init(
      icon: "paintbrush.fill",
      iconColor: .githubInfo,
      title: "모양",
      subtitle: "테마 및 모드 설정",
      badgeCount: nil,
      type: .appearance,
      hasChevron: true
    ),
    .init(
      icon: "questionmark.circle.fill",
      iconColor: .githubSecondaryText,
      title: "도움말",
      subtitle: "지원 및 문의",
      badgeCount: nil,
      type: .help,
      hasChevron: true
    ),
    .init(
      icon: "rectangle.portrait.and.arrow.right.fill",
      iconColor: .githubRed,
      title: "로그아웃",
      subtitle: nil,
      badgeCount: nil,
      type: .signOut,
      hasChevron: false
    )
  ]
}

extension [ProfileModel.RepositoryItem] {
  static let `default`: Self = [
    .init(
      id: 0,
      name: "ysnzp_random_flutter",
      fullName: "lks574/ysnzp_random_flutter",
      description: "flutter 점소",
      language: "Dart",
      languageColor: .githubInfo,
      starCount: 0,
      forkCount: 0,
      isPrivate: false,
      updatedAt: "1일 전"
    ),
    .init(
      id: 1,
      name: "flutter_staggered_grid",
      fullName: "lks574/flutter_staggered_grid",
      description: "플러터 그리드뷰 구현",
      language: "Dart",
      languageColor: .githubInfo,
      starCount: 3,
      forkCount: 1,
      isPrivate: false,
      updatedAt: "3일 전"
    ),
    .init(
      id: 2,
      name: "ios_practice",
      fullName: "lks574/ios_practice",
      description: "iOS 개발 연습 프로젝트",
      language: "Swift",
      languageColor: .githubOrange,
      starCount: 5,
      forkCount: 2,
      isPrivate: true,
      updatedAt: "1주일 전"
    )
  ]
}

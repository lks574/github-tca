import SwiftUI

extension GitHubTabBar {

  // MARK: - GitHub 스타일 탭바
  struct TabBar: View {
    @Binding var selectedTab: GitHubTab

    var body: some View {
      HStack(spacing: 0) {
        ForEach(GitHubTab.allCases, id: \.self) { tab in
          GitHubTabBarItem(
            tab: tab,
            isSelected: selectedTab == tab,
            action: {
              selectedTab = tab
            }
          )
        }
      }
      .padding(.top, GitHubSpacing.sm)
      .padding(.bottom, GitHubSpacing.md)
      .background(Color.githubCardBackground)
      .overlay(
        Rectangle()
          .frame(height: 0.5)
          .foregroundColor(.githubBorder),
        alignment: .top
      )
    }
  }

  // MARK: - 탭바 아이템
  private struct GitHubTabBarItem: View {
    let tab: GitHubTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        VStack(spacing: GitHubSpacing.xxs) {
          Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
            .font(.system(size: GitHubIconSize.medium, weight: .medium))
            .foregroundColor(isSelected ? .githubBlue : .githubTertiaryText)

          Text(tab.title)
            .font(.githubCaption2)
            .foregroundColor(isSelected ? .githubBlue : .githubTertiaryText)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  // MARK: - 탭 정의
  enum GitHubTab: String, CaseIterable {
    case home = "home"
    case notifications = "notifications"
    case explore = "explore"
    case profile = "profile"

    var title: String {
      switch self {
      case .home:
        return "홈"
      case .notifications:
        return "받은 편지함"
      case .explore:
        return "탐색"
      case .profile:
        return "프로필"
      }
    }

    var icon: String {
      switch self {
      case .home:
        return "house"
      case .notifications:
        return "bell"
      case .explore:
        return "safari"
      case .profile:
        return "person.crop.circle"
      }
    }

    var selectedIcon: String {
      switch self {
      case .home:
        return "house.fill"
      case .notifications:
        return "bell.fill"
      case .explore:
        return "safari.fill"
      case .profile:
        return "person.crop.circle.fill"
      }
    }
  }


}

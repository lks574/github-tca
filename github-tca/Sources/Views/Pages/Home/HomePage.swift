import Foundation
import ComposableArchitecture
import SwiftUI

enum HomePage {
  struct RootView: View {
    @Bindable var store: StoreOf<HomeReducer>

    var body: some View {
      ScrollView {
        LazyVStack(spacing: GitHubSpacing.lg) {
          // 검색바
          GitHubSearchBar(
            text: $store.searchText,
            placeholder: "GitHub 검색"
          )
          
          // 내 작업 섹션
          VStack(spacing: GitHubSpacing.md) {
            GitHubSectionHeader("내 작업") {
              store.send(.loadMoreItems)
            }
            
            LazyVStack(spacing: GitHubSpacing.sm) {
              ForEach(store.menuItems) { menuItem in
                HomeMenuItemView(
                  item: menuItem,
                  onTap: { 
                    store.send(.menuItemTapped(menuItem.type))
                  }
                )
              }
            }
          }
          
          // 즐겨찾기 섹션
          GitHubBookmarkSection {
            store.send(.addBookmarkTapped)
          }
          
          // 바로 가기 섹션
          GitHubQuickAccessSection(items: store.quickAccessItems) {
            store.send(.quickAccessTapped)
          }
          
          // 최근 항목 섹션
          GitHubRecentSection(items: store.recentItems) { item in
            store.send(.recentItemTapped(item))
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .background(Color.githubBackground)
      .navigationTitle("홈")
      .githubNavigationStyle()
    }
  }

  // MARK: - Home Menu Item View
  private struct HomeMenuItemView: View {
    let item: HomeMenuItem
    let onTap: () async -> Void

    var body: some View {
      GitHubListItem(
        icon: item.icon,
        iconColor: item.iconColor,
        title: item.title,
        action: onTap
      )
    }
  }

  // MARK: - 최근 항목 섹션
  private struct GitHubRecentSection: View {
    let items: [RecentItem]
    let onItemTap: (RecentItem) -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        GitHubSectionHeader("최근 항목") {
          // 더보기 액션
        }

        GitHubCard {
          VStack(spacing: GitHubSpacing.md) {
            ForEach(items) { item in
              HStack(spacing: GitHubSpacing.md) {
                Image(systemName: item.icon)
                  .font(.system(size: GitHubIconSize.medium))
                  .foregroundColor(item.iconColor)
                  .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)

                VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
                  Text(item.title)
                    .githubStyle(.primaryText)
                    .multilineTextAlignment(.leading)

                  Text(item.subtitle)
                    .githubStyle(.secondaryText)
                    .multilineTextAlignment(.leading)
                }

                Spacer()
              }
              .padding(.vertical, GitHubSpacing.sm)
              .onTapGesture {
                onItemTap(item)
              }

              if item.id != items.last?.id {
                Divider()
                  .background(Color.githubSeparator)
              }
            }
          }
          .padding(.horizontal, GitHubSpacing.sm)
        }
      }
    }
  }

  // MARK: - 빠른 액세스 섹션
  private struct GitHubQuickAccessSection: View {
    let items: [QuickAccessItem]
    let onItemTap: () -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        GitHubSectionHeader("바로 가기") {
          // 더보기 액션
        }

        GitHubCard {
          VStack(spacing: GitHubSpacing.lg) {
            // 아이콘 그리드 (2줄로 배치)
            VStack(spacing: GitHubSpacing.md) {
              HStack(spacing: GitHubSpacing.md) {
                QuickAccessIcon(
                  icon: "bolt.fill",
                  color: .githubBlue,
                  title: "Actions"
                )
                QuickAccessIcon(
                  icon: "clock.fill",
                  color: .githubGreen,
                  title: "History"
                )
                QuickAccessIcon(
                  icon: "arrow.triangle.merge",
                  color: .githubBlue,
                  title: "PRs"
                )
                QuickAccessIcon(
                  icon: "bubble.left.and.bubble.right.fill",
                  color: .githubPurple,
                  title: "Discussions"
                )
              }
              
              HStack(spacing: GitHubSpacing.md) {
                QuickAccessIcon(
                  icon: "person.3.fill",
                  color: .githubOrange,
                  title: "Teams"
                )
                QuickAccessIcon(
                  icon: "tray.full.fill",
                  color: .githubSecondaryText,
                  title: "Projects"
                )
                QuickAccessIcon(
                  icon: "square.stack.3d.up.fill",
                  color: .githubSecondaryText,
                  title: "Packages"
                )
                QuickAccessIcon(
                  icon: "doc.text.fill",
                  color: .githubSecondaryText,
                  title: "Docs"
                )
              }
            }
            .padding(.horizontal, GitHubSpacing.sm)

            VStack(spacing: GitHubSpacing.xs) {
              Text("탭 한 번에, 필요한 항목 이용 가능")
                .githubStyle(.primaryText)
                .multilineTextAlignment(.center)

              Text("Issue, Pull Request 또는 Discussion 목록에")
                .githubStyle(.secondaryText)
                .multilineTextAlignment(.center)

              Text("바로게 액세스")
                .githubStyle(.secondaryText)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, GitHubSpacing.md)

            Button(action: onItemTap) {
              Text("시작")
                .font(.githubSubheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GitHubSpacing.md)
                .background(Color.githubBlue)
                .cornerRadius(GitHubCornerRadius.medium)
            }
            .padding(.horizontal, GitHubSpacing.md)
          }
          .padding(.vertical, GitHubSpacing.sm)
        }
      }
    }
  }

  // MARK: - 빠른 액세스 아이콘
  private struct QuickAccessIcon: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
      VStack(spacing: GitHubSpacing.xxs) {
        Image(systemName: icon)
          .font(.system(size: GitHubIconSize.medium))
          .foregroundColor(color)
          .frame(width: GitHubIconSize.xlarge, height: GitHubIconSize.xlarge)
        
        Text(title)
          .font(.githubCaption2)
          .foregroundColor(.githubTertiaryText)
          .lineLimit(1)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
    }
  }

  // MARK: - 즐겨찾기 섹션
  private struct GitHubBookmarkSection: View {
    let onAddBookmark: () -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        GitHubSectionHeader("즐겨찾기") {
          // 더보기 액션
        }

        GitHubCard {
          VStack(spacing: GitHubSpacing.md) {
            HStack(spacing: GitHubSpacing.sm) {
              Image(systemName: "star.fill")
                .font(.system(size: GitHubIconSize.large))
                .foregroundColor(.githubWarning)

              Text("별표 표시")
                .githubStyle(.primaryText)

              Spacer()

              Image(systemName: "chevron.right")
                .font(.system(size: GitHubIconSize.small))
                .foregroundColor(.githubTertiaryText)
            }
            .padding(.horizontal, GitHubSpacing.md)
            .padding(.vertical, GitHubSpacing.sm)
            .background(Color.githubSecondaryBackground)
            .cornerRadius(GitHubCornerRadius.medium)
            .onTapGesture {
              onAddBookmark()
            }
          }
        }
      }
    }
  }
}

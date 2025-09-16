import Foundation
import ComposableArchitecture
import SwiftUI

enum HomePage {
  struct RootView: View {
    @Bindable var store: StoreOf<HomeReducer>

    var body: some View {
      ScrollView {
        VStack(spacing: GitHubSpacing.lg) {
          // 검색바
          GitHubSearchBar(
            text: $store.searchText,
            placeholder: "GitHub 검색"
          )
          .padding(.horizontal, GitHubSpacing.screenPadding)
          
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
            .padding(.horizontal, GitHubSpacing.screenPadding)
          }
          
          Spacer()
        }
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
}

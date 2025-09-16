import SwiftUI
import ComposableArchitecture

enum ExplorePage {
  struct RootView: View {
    @Bindable var store: StoreOf<ExploreReducer>
    
    init(store: StoreOf<ExploreReducer>) {
      self.store = store
    }
    
    var body: some View {
      ScrollView {
        LazyVStack(spacing: GitHubSpacing.lg) {
          // 검색 섹션
          VStack(spacing: GitHubSpacing.md) {
            GitHubSectionHeader("검색")
            
            LazyVStack(spacing: GitHubSpacing.sm) {
              ForEach(store.searchItems) { item in
                ExploreSearchItem(item: item) {
                  store.send(.searchItemTapped(item))
                }
              }
            }
          }
          
          // 활동 섹션
          VStack(spacing: GitHubSpacing.md) {
            GitHubSectionHeader("활동") {
              // 더보기 액션
            }
            
            LazyVStack(spacing: GitHubSpacing.sm) {
              ForEach(store.activityItems) { activity in
                ExploreActivityItem(activity: activity) {
                  store.send(.activityItemTapped(activity))
                }
              }
              
              ForEach(store.popularRepositories) { repository in
                ExploreRepositoryCard(repository: repository) {
                  store.send(.repositoryTapped(repository))
                }
              }
            }
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .background(Color.githubBackground)
      .navigationTitle("탐색")
      .githubNavigationStyle()
    }
  }
  
  // MARK: - 검색 아이템
  private struct ExploreSearchItem: View {
    let item: ExploreModel.SearchItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.md) {
          RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
            .fill(item.iconColor)
            .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)
            .overlay(
              Image(systemName: item.icon)
                .font(.system(size: GitHubIconSize.medium, weight: .medium))
                .foregroundColor(.white)
            )
          
          Text(item.title)
            .githubStyle(.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          Image(systemName: "chevron.right")
            .font(.system(size: GitHubIconSize.small, weight: .medium))
            .foregroundColor(.githubTertiaryText)
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.md)
        .background(Color.githubCardBackground)
        .cornerRadius(GitHubCornerRadius.medium)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - 활동 아이템
  private struct ExploreActivityItem: View {
    let activity: ExploreModel.ActivityItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        VStack(spacing: GitHubSpacing.sm) {
          HStack(spacing: GitHubSpacing.sm) {
            // 사용자 아바타
            Circle()
              .fill(Color.githubSecondaryText)
              .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)
              .overlay(
                Image(systemName: "person.fill")
                  .font(.system(size: GitHubIconSize.medium))
                  .foregroundColor(.white)
              )
            
            VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
              HStack {
                Text(activity.fullName)
                  .githubStyle(.primaryText)
                  .fontWeight(.medium)
                
                Text(activity.timeAgo)
                  .githubStyle(.captionText)
                
                Spacer()
              }
              
              Text(activity.action)
                .githubStyle(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.sm)
        .background(Color.githubCardBackground)
        .cornerRadius(GitHubCornerRadius.medium)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - 리포지토리 카드
  private struct ExploreRepositoryCard: View {
    let repository: ExploreModel.PopularRepository
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        GitHubCard {
          VStack(spacing: GitHubSpacing.md) {
            // 헤더
            HStack(spacing: GitHubSpacing.sm) {
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: GitHubIconSize.medium))
                .foregroundColor(.githubSecondaryText)
              
              VStack(alignment: .leading, spacing: 2) {
                Text(repository.fullName)
                  .githubStyle(.primaryText)
                  .fontWeight(.medium)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              
              Spacer()
            }
            
            // 버전 정보
            HStack {
              Text("1.22.2")
                .font(.githubTitle2)
                .fontWeight(.bold)
                .foregroundColor(.githubPrimaryText)
              
              Spacer()
            }
            
            // What's Changed 섹션
            VStack(alignment: .leading, spacing: GitHubSpacing.xs) {
              Text("What's Changed")
                .font(.githubHeadline)
                .foregroundColor(.githubPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              HStack {
                Text("•")
                  .foregroundColor(.githubSecondaryText)
                
                Text("Fixed: Better cancellation detection in")
                  .githubStyle(.secondaryText)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
          }
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.md)
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}

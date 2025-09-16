import SwiftUI
import ComposableArchitecture

enum NotificationsPage {
  struct RootView: View {
    @Bindable var store: StoreOf<NotificationsReducer>
    
    var body: some View {
      VStack(spacing: 0) {
        // 필터 섹션
        FilterSection(store: store)
        
        // 알림 목록
        if store.filteredNotifications.isEmpty {
          EmptyStateView(selectedFilter: store.selectedFilter)
        } else {
          NotificationsList(store: store)
        }
      }
      .background(Color.githubBackground)
      .navigationTitle("받은 편지함")
      .githubNavigationStyle()
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button("모두 읽음") {
            store.send(.markAllAsRead)
          }
          .font(.githubSubheadline)
          .foregroundColor(.githubBlue)
          .disabled(store.unreadCount == 0)
        }
      }
      .onAppear {
        store.send(.loadNotifications)
      }
      .refreshable {
        store.send(.refreshNotifications)
      }
    }
  }
  
  // MARK: - Filter Section
  private struct FilterSection: View {
    @Bindable var store: StoreOf<NotificationsReducer>
    
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        // 검색바
        GitHubSearchBar(
          text: $store.searchText,
          placeholder: "알림 검색"
        )
        .padding(.horizontal, GitHubSpacing.screenPadding)
        
        // 필터 버튼들
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: GitHubSpacing.sm) {
            ForEach(NotificationsModel.FilterType.allCases, id: \.rawValue) { filter in
              FilterButton(
                title: filter.title,
                isSelected: store.selectedFilter == filter,
                count: filter == .unread ? store.unreadCount : nil
              ) {
                store.send(.filterChanged(filter))
              }
            }
            
            // 리포지토리 필터
            Menu {
              Button("모든 리포지토리") {
                store.send(.repositoryFilterChanged(nil))
              }
              
              ForEach(store.repositoryFilters) { repo in
                Button("\(repo.name) (\(repo.count))") {
                  store.send(.repositoryFilterChanged(repo.name))
                }
              }
            } label: {
              HStack(spacing: GitHubSpacing.xs) {
                Text(store.selectedRepository ?? "리포지토리")
                Image(systemName: "chevron.down")
                  .font(.system(size: GitHubIconSize.small))
              }
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
              .padding(.horizontal, GitHubSpacing.md)
              .padding(.vertical, GitHubSpacing.sm)
              .background(
                RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
                  .stroke(Color.githubBorder, lineWidth: 1)
              )
            }
          }
          .padding(.horizontal, GitHubSpacing.screenPadding)
        }
      }
      .padding(.vertical, GitHubSpacing.sm)
      .background(Color.githubBackground)
    }
  }
  
  // MARK: - Filter Button
  private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let action: () -> Void
    
    var body: some View {
      Button(action: action) {
        HStack(spacing: GitHubSpacing.xs) {
          Text(title)
          
          if let count = count, count > 0 {
            Text("\(count)")
              .font(.githubCaption)
              .foregroundColor(isSelected ? .white : .githubSecondaryText)
              .padding(.horizontal, GitHubSpacing.xs)
              .padding(.vertical, 2)
              .background(
                RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
                  .fill(isSelected ? Color.white.opacity(0.3) : Color.githubTertiaryBackground)
              )
          }
        }
        .font(.githubSubheadline)
        .foregroundColor(isSelected ? .white : .githubSecondaryText)
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.sm)
        .background(
          RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
            .fill(isSelected ? Color.githubBlue : Color.githubCardBackground)
        )
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - Notifications List
  private struct NotificationsList: View {
    @Bindable var store: StoreOf<NotificationsReducer>
    
    var body: some View {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(store.filteredNotifications) { notification in
            NotificationRow(
              notification: notification,
              onTap: {
                store.send(.notificationTapped(notification))
              }
            )
            
            Divider()
              .background(Color.githubSeparator)
          }
        }
      }
    }
  }
  
  // MARK: - Notification Row
  private struct NotificationRow: View {
    let notification: NotificationsModel.NotificationItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.md) {
          // 읽음/읽지 않음 표시
          Circle()
            .fill(notification.isUnread ? Color.githubBlue : Color.clear)
            .frame(width: 8, height: 8)
          
          // 아이콘
          Image(systemName: notification.type.icon)
            .font(.system(size: GitHubIconSize.medium))
            .foregroundColor(notification.type.iconColor)
            .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)
          
          // 내용
          VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
            HStack {
              Text(notification.repository)
                .font(.githubSubheadline)
                .foregroundColor(.githubSecondaryText)
              
              Spacer()
              
              Text(notification.timeAgo)
                .font(.githubCaption)
                .foregroundColor(.githubTertiaryText)
            }
            
            Text(notification.title)
              .font(.githubSubheadline)
              .fontWeight(notification.isUnread ? .medium : .regular)
              .foregroundColor(notification.isUnread ? .githubPrimaryText : .githubSecondaryText)
              .multilineTextAlignment(.leading)
              .lineLimit(2)
            
            if !notification.subtitle.isEmpty {
              Text(notification.subtitle)
                .font(.githubCaption)
                .foregroundColor(.githubTertiaryText)
                .lineLimit(1)
            }
          }
          
          // 화살표
          Image(systemName: "chevron.right")
            .font(.system(size: GitHubIconSize.small))
            .foregroundColor(.githubTertiaryText)
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.vertical, GitHubSpacing.md)
        .background(
          notification.isUnread ? 
            Color.githubBlue.opacity(0.05) : 
            Color.githubBackground
        )
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - Empty State
  private struct EmptyStateView: View {
    let selectedFilter: NotificationsModel.FilterType
    
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Spacer()
        
        VStack(spacing: GitHubSpacing.md) {
          Image(systemName: emptyStateIcon)
            .font(.system(size: 60))
            .foregroundColor(.githubTertiaryText)
          
          Text(emptyStateTitle)
            .githubStyle(.primaryText)
            .multilineTextAlignment(.center)
          
          Text(emptyStateSubtitle)
            .githubStyle(.secondaryText)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateIcon: String {
      switch selectedFilter {
      case .all:
        return "bell.slash"
      case .unread:
        return "envelope.open"
      case .participating:
        return "person.2"
      }
    }
    
    private var emptyStateTitle: String {
      switch selectedFilter {
      case .all:
        return "중요한 사항을 놓치지 마세요."
      case .unread:
        return "읽지 않은 알림이 없습니다"
      case .participating:
        return "참여 중인 대화가 없습니다"
      }
    }
    
    private var emptyStateSubtitle: String {
      switch selectedFilter {
      case .all:
        return "푸시 알림, 작업 시간 및 삶착 알기 작업으로 알림 환경을 사용자 지정합니다."
      case .unread:
        return "모든 알림을 확인하셨습니다!"
      case .participating:
        return "멘션되거나 요청된 리뷰가 있으면\n여기에 표시됩니다"
      }
    }
  }
}

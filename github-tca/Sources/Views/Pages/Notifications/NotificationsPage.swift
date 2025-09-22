import SwiftUI
import ComposableArchitecture

enum NotificationsPage {
  struct RootView: View {
    @Bindable var store: StoreOf<NotificationsReducer>
    @State private var showPromptSection: Bool = true
    
    var body: some View {
      // 단일 ScrollView로 모든 컨텐츠 포함
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 0) {
            // 스크롤 감지를 위한 투명 GeometryReader
            GeometryReader { geometry in
              Color.clear
                .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                  withAnimation(.easeInOut(duration: 0.25)) {
                    showPromptSection = newValue > -30 // 30px 스크롤하면 숨김
                  }
                }
            }
            .frame(height: 0)
            
            // 필터 섹션 (스크롤됨)
            FilterSection(store: store)
            
            // 안내 메시지 (스크롤 시 숨김)
            if showPromptSection {
              NotificationPromptSection {
                store.send(.configureNotificationsTapped)
              }
              .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // 알림 목록 또는 빈 상태
            if store.filteredNotifications.isEmpty {
              EmptyStateView(selectedFilter: store.selectedFilter)
            } else {
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
        .refreshable {
          store.send(.refreshNotifications)
        }
      }
      .background(Color.githubBackground)
      .navigationTitle("받은 편지함")
      .navigationBarTitleDisplayMode(.large)
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
    }
  }
  
  // MARK: - Notification Prompt Section
  private struct NotificationPromptSection: View {
    let onConfigureTapped: () -> Void
    
    var body: some View {
      HStack(spacing: GitHubSpacing.md) {
        // 빨간 알림 아이콘
        ZStack {
          Circle()
            .fill(Color.red)
            .frame(width: 48, height: 48)
          
          Image(systemName: "bell.fill")
            .foregroundColor(.white)
            .font(.system(size: 20))
        }
        
        // 메시지 영역
        VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
          Text("중요한 사항을 놓치지 마세요.")
            .font(.githubHeadline)
            .foregroundColor(.githubPrimaryText)
          
          Text("푸시 알림, 작업 시간 및 삶착 알기 작업으로 알림 환경을 사용자 지정합니다.")
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }
        
        Spacer()
        
        // 구성 버튼
        Button("구성") {
          onConfigureTapped()
        }
        .font(.githubCallout)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.sm)
        .background(Color.githubBlue)
        .cornerRadius(GitHubCornerRadius.button)
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.vertical, GitHubSpacing.md)
      .background(Color.githubBackground)
    }
  }
  
  // MARK: - Filter Section
  private struct FilterSection: View {
    @Bindable var store: StoreOf<NotificationsReducer>
    
    var body: some View {
      // 필터 버튼들 (검색바 제거)
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
  
  // MARK: - Notification Row
  private struct NotificationRow: View {
    let notification: NotificationsModel.NotificationItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.md) {
          // GitHub 스타일 아이콘
          GitHubNotificationIcon(type: notification.type)
          
          // 메인 내용
          VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
            // 리포지토리 정보와 시간
            HStack {
              // 읽음/읽지 않음 표시 원
              Circle()
                .fill(notification.isUnread ? Color.githubBlue : Color.clear)
                .frame(width: 8, height: 8)
              
              HStack(spacing: 4) {
                Text(formatRepositoryName(notification.repository))
                  .font(.githubCaption)
                  .foregroundColor(.githubSecondaryText)
                
                if let issueNumber = notification.issueNumber {
                  Text(issueNumber)
                    .font(.githubCaption)
                    .foregroundColor(.githubSecondaryText)
                }
              }
              
              Spacer()
              
              Text(notification.timeAgo)
                .font(.githubCaption)
                .foregroundColor(.githubTertiaryText)
            }
            
            // 제목
            Text(notification.title)
              .font(.githubCallout)
              .fontWeight(notification.isUnread ? .semibold : .regular)
              .foregroundColor(.githubPrimaryText)
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
            
            // 부제목 (작업명 등)
            if !notification.subtitle.isEmpty {
              HStack(spacing: GitHubSpacing.xs) {
                Text(notification.avatar)
                  .font(.githubCaption)
                
                Text(notification.subtitle)
                  .font(.githubCaption)
                  .foregroundColor(.githubSecondaryText)
              }
            }
          }
          
          // 오른쪽 배지 (알림 개수)
          if notification.isUnread {
            NotificationBadge(count: getNotificationCount(for: notification))
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.vertical, GitHubSpacing.md)
        .background(Color.githubBackground)
      }
      .buttonStyle(PlainButtonStyle())
    }
    
    private func formatRepositoryName(_ repository: String) -> String {
      // "owner/repo" 형식을 "owner / repo" 로 변환
      return repository.replacingOccurrences(of: "/", with: " / ")
    }
    
    private func getNotificationCount(for notification: NotificationsModel.NotificationItem) -> Int {
      // 실제로는 API에서 받아와야 하지만, 임시로 랜덤 값 사용
      switch notification.type {
      case .issue, .pullRequest:
        return Int.random(in: 1...9)
      case .release:
        return 1
      default:
        return Int.random(in: 1...5)
      }
    }
  }
  
  // MARK: - GitHub Notification Icon
  private struct GitHubNotificationIcon: View {
    let type: NotificationsModel.NotificationItem.NotificationType
    
    var body: some View {
      ZStack {
        Circle()
          .fill(iconBackgroundColor)
          .frame(width: 32, height: 32)
        
        Image(systemName: iconName)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(iconColor)
      }
    }
    
    private var iconName: String {
      switch type {
      case .issue:
        return "exclamationmark.circle"
      case .pullRequest:
        return "arrow.triangle.merge"
      case .release:
        return "tag"
      case .commit:
        return "circle"
      case .discussion:
        return "bubble.left.and.bubble.right"
      case .checkSuite:
        return "checkmark.circle"
      case .repositoryVulnerabilityAlert:
        return "shield.lefthalf.filled"
      case .unknown:
        return "bell"
      }
    }
    
    private var iconColor: Color {
      switch type {
      case .issue:
        return .white
      case .pullRequest:
        return .white
      case .release:
        return .white
      case .commit:
        return .githubSecondaryText
      case .discussion:
        return .white
      case .checkSuite:
        return .white
      case .repositoryVulnerabilityAlert:
        return .white
      case .unknown:
        return .white
      }
    }
    
    private var iconBackgroundColor: Color {
      switch type {
      case .issue:
        return .githubGreen
      case .pullRequest:
        return .githubBlue
      case .release:
        return .githubOrange
      case .commit:
        return .githubTertiaryBackground
      case .discussion:
        return .githubPurple
      case .checkSuite:
        return .githubGreen
      case .repositoryVulnerabilityAlert:
        return .githubRed
      case .unknown:
        return .githubSecondaryText
      }
    }
  }
  
  // MARK: - Notification Badge
  private struct NotificationBadge: View {
    let count: Int
    
    var body: some View {
      if count > 0 {
        Text("\(count)")
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(.white)
          .padding(.horizontal, count > 9 ? 6 : 4)
          .padding(.vertical, 2)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.githubBlue)
          )
          .frame(minWidth: 20, minHeight: 16)
      }
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
            .font(.githubTitle3)
            .foregroundColor(.githubPrimaryText)
            .multilineTextAlignment(.center)
          
          Text(emptyStateSubtitle)
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
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

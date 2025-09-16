import ComposableArchitecture
import SwiftUI

@Reducer
struct NotificationsReducer {
  @Dependency(\.navigation) var navigation
  
  @ObservableState
  struct State: Equatable {
    var notifications: [NotificationsModel.NotificationItem] = .default
    var repositoryFilters: [NotificationsModel.RepositoryFilter] = .default
    var selectedFilter: NotificationsModel.FilterType = .all
    var selectedRepository: String? = nil
    var searchText = ""
    var isLoading = false
    
    // 필터링된 알림 목록
    var filteredNotifications: [NotificationsModel.NotificationItem] {
      var filtered = notifications
      
      // 검색 텍스트 필터링
      if !searchText.isEmpty {
        filtered = filtered.filter { notification in
          notification.title.localizedCaseInsensitiveContains(searchText) ||
          notification.repository.localizedCaseInsensitiveContains(searchText)
        }
      }
      
      // 선택된 리포지토리 필터링
      if let selectedRepo = selectedRepository {
        filtered = filtered.filter { $0.repository == selectedRepo }
      }
      
      // 읽음/읽지 않음 필터링
      switch selectedFilter {
      case .all:
        break
      case .unread:
        filtered = filtered.filter { $0.isUnread }
      case .participating:
        // 참여 중인 알림만 (예: 멘션, 리뷰 요청 등)
        filtered = filtered.filter { notification in
          [.mention, .review].contains(notification.type)
        }
      }
      
      return filtered
    }
    
    // 읽지 않은 알림 개수
    var unreadCount: Int {
      notifications.filter { $0.isUnread }.count
    }
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case loadNotifications
    case refreshNotifications
    case notificationTapped(NotificationsModel.NotificationItem)
    case markAsRead(NotificationsModel.NotificationItem)
    case markAllAsRead
    case filterChanged(NotificationsModel.FilterType)
    case repositoryFilterChanged(String?)
    case clearAllNotifications
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .loadNotifications:
        state.isLoading = true
        return .run { send in
          // 네트워크 요청 시뮬레이션
          try await Task.sleep(nanoseconds: 1_000_000_000)
          await send(.binding(.set(\.isLoading, false)))
        }
        
      case .refreshNotifications:
        state.isLoading = true
        // 새로운 알림 데이터 로드
        return .run { send in
          try await Task.sleep(nanoseconds: 500_000_000)
          await send(.binding(.set(\.isLoading, false)))
        }
        
      case let .notificationTapped(notification):
        // 알림을 읽음으로 표시하고 해당 페이지로 이동
        return .run { send in
          await send(.markAsRead(notification))
          print("알림 탭됨: \(notification.title)")
        }
        
      case let .markAsRead(notification):
        // 특정 알림을 읽음으로 표시
        state.notifications = state.notifications.map { item in
          if item.id == notification.id {
            var updatedItem = item
            updatedItem = NotificationsModel.NotificationItem(
              repository: item.repository,
              title: item.title,
              subtitle: item.subtitle,
              type: item.type,
              timeAgo: item.timeAgo,
              isUnread: false,
              avatar: item.avatar
            )
            return updatedItem
          }
          return item
        }
        return .none
        
      case .markAllAsRead:
        // 모든 알림을 읽음으로 표시
        state.notifications = state.notifications.map { item in
          NotificationsModel.NotificationItem(
            repository: item.repository,
            title: item.title,
            subtitle: item.subtitle,
            type: item.type,
            timeAgo: item.timeAgo,
            isUnread: false,
            avatar: item.avatar
          )
        }
        return .none
        
      case let .filterChanged(filter):
        state.selectedFilter = filter
        return .none
        
      case let .repositoryFilterChanged(repository):
        state.selectedRepository = repository
        return .none
        
      case .clearAllNotifications:
        state.notifications.removeAll()
        return .none
      }
    }
  }
}

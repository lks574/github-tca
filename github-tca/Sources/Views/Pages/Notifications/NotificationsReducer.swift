import ComposableArchitecture
import SwiftUI

@Reducer
struct NotificationsReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.gitHubClient) var gitHubClient
  
  @ObservableState
  struct State: Equatable {
    var notifications: [NotificationsModel.NotificationItem] = .default
    var repositoryFilters: [NotificationsModel.RepositoryFilter] = .default
    var selectedFilter: NotificationsModel.FilterType = .all
    var selectedRepository: String? = nil
    var isLoading = false
    
    // 필터링된 알림 목록
    var filteredNotifications: [NotificationsModel.NotificationItem] {
      var filtered = notifications
      
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
        // 참여 중인 알림만 (mention, assign, review_requested 등)
        filtered = filtered.filter { notification in
          ["mention", "assign", "review_requested", "author"].contains(notification.reason)
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
    case configureNotificationsTapped // 구성 버튼 액션
    
    // API 응답 액션들
    case notificationsResponse(Result<[GitHubNotification], Error>)
    case markAsReadResponse(Result<Void, Error>)
    case markAllAsReadResponse(Result<Void, Error>)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .loadNotifications:
        state.isLoading = true
        return .run { [filter = state.selectedFilter] send in
          do {
            let all = filter == .all
            let participating = filter == .participating
            let notifications = try await gitHubClient.getNotifications(
              all, participating, nil, nil, 1, 50
            )
            await send(.notificationsResponse(.success(notifications)))
          } catch {
            await send(.notificationsResponse(.failure(error)))
          }
        }
        
      case .refreshNotifications:
        state.isLoading = true
        return .run { [filter = state.selectedFilter] send in
          do {
            let all = filter == .all
            let participating = filter == .participating
            let notifications = try await gitHubClient.getNotifications(
              all, participating, nil, nil, 1, 50
            )
            await send(.notificationsResponse(.success(notifications)))
          } catch {
            await send(.notificationsResponse(.failure(error)))
          }
        }
        
      case let .notificationTapped(notification):
        // 알림을 읽음으로 표시하고 상세 화면으로 이동
        return .run { _ in
          await navigation.goToNotificationDetail(notification)
          print("알림 탭됨: \(notification.title)")
        }
        
      case let .markAsRead(notification):
        return .run { send in
          do {
            try await gitHubClient.markNotificationAsRead(notification.id)
            await send(.markAsReadResponse(.success(())))
          } catch {
            await send(.markAsReadResponse(.failure(error)))
          }
        }
        
      case .markAllAsRead:
        return .run { send in
          do {
            let currentTime = ISO8601DateFormatter().string(from: Date())
            try await gitHubClient.markAllNotificationsAsRead(currentTime)
            await send(.markAllAsReadResponse(.success(())))
          } catch {
            await send(.markAllAsReadResponse(.failure(error)))
          }
        }
        
      case let .filterChanged(filter):
        state.selectedFilter = filter
        return .send(.loadNotifications)
        
      case let .repositoryFilterChanged(repository):
        state.selectedRepository = repository
        return .none
        
      case .clearAllNotifications:
        state.notifications.removeAll()
        return .none
        
      case .configureNotificationsTapped:
        // TODO: 알림 설정 화면으로 이동 또는 시스템 설정으로 이동
        print("🔧 알림 구성 버튼 탭됨")
        return .none
        
      // API 응답 처리
      case .notificationsResponse(.success(let githubNotifications)):
        state.isLoading = false
        state.notifications = githubNotifications.map { $0.toNotificationItem() }
        
        // 리포지토리 필터 업데이트
        let repositoryNames = Array(Set(githubNotifications.map { $0.repository.fullName }))
        state.repositoryFilters = repositoryNames.map { repoName in
          let count = githubNotifications.filter { $0.repository.fullName == repoName }.count
          return NotificationsModel.RepositoryFilter(name: repoName, count: count)
        }.sorted { $0.count > $1.count }
        
        print("✅ 알림 \(githubNotifications.count)개 로드 완료")
        return .none
        
      case .notificationsResponse(.failure(let error)):
        state.isLoading = false
        print("❌ 알림 로드 실패: \(error)")
        return .none
        
      case .markAsReadResponse(.success):
        // 로컬 상태에서 해당 알림을 읽음으로 표시
        return .send(.refreshNotifications)
        
      case .markAsReadResponse(.failure(let error)):
        print("❌ 알림 읽음 처리 실패: \(error)")
        return .none
        
      case .markAllAsReadResponse(.success):
        // 로컬 상태에서 모든 알림을 읽음으로 표시
        return .send(.refreshNotifications)
        
      case .markAllAsReadResponse(.failure(let error)):
        print("❌ 모든 알림 읽음 처리 실패: \(error)")
        return .none
      }
    }
  }
}

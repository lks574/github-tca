import ComposableArchitecture
import SwiftUI

@Reducer
struct NotificationDetailReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.gitHubClient) var gitHubClient
  
  @ObservableState
  struct State: Equatable {
    let notification: NotificationsModel.NotificationItem
    var issueDetails: NotificationDetailModel.IssueDetails?
    var timelineEvents: [NotificationDetailModel.TimelineEvent] = []
    var isLoading = false
    var error: String?
    
    init(notification: NotificationsModel.NotificationItem) {
      self.notification = notification
      // 기본 데이터로 초기화
      self.issueDetails = .default
      self.timelineEvents = .default
    }
  }
  
  enum Action: Sendable {
    case onAppear
    case loadIssueDetails
    case loadTimelineEvents
    case timelineEventTapped(NotificationDetailModel.TimelineEvent)
    case shareButtonTapped
    case moreButtonTapped
    case reactionTapped(NotificationDetailModel.Reaction, NotificationDetailModel.TimelineEvent)
    
    // API 응답 액션들
    case issueDetailsResponse(Result<NotificationDetailModel.IssueDetails, Error>)
    case timelineEventsResponse(Result<[NotificationDetailModel.TimelineEvent], Error>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          .send(.loadIssueDetails),
          .send(.loadTimelineEvents)
        )
        
      case .loadIssueDetails:
        state.isLoading = true
        state.error = nil
        
        // TODO: 실제 API 호출
        // 현재는 기본 데이터 사용
        return .send(.issueDetailsResponse(.success(.default)))
        
      case .loadTimelineEvents:
        // TODO: 실제 API 호출
        // 현재는 기본 데이터 사용
        return .send(.timelineEventsResponse(.success(.default)))
        
      case let .timelineEventTapped(event):
        print("📝 타임라인 이벤트 탭됨: \(event.description)")
        
        // 댓글이면 상세 보기, 커밋이면 커밋 상세 등
        switch event.type {
        case .comment:
          // 댓글 상세 보기 또는 편집
          break
        case .commit:
          // 커밋 상세 보기
          break
        default:
          break
        }
        
        return .none
        
      case .shareButtonTapped:
        print("📤 공유 버튼 탭됨")
        // TODO: 시스템 공유 시트 표시
        return .none
        
      case .moreButtonTapped:
        print("⋯ 더보기 버튼 탭됨")
        // TODO: 액션 시트 표시 (구독 해제, 알림 설정 등)
        return .none
        
      case let .reactionTapped(reaction, event):
        print("😀 반응 탭됨: \(reaction.emoji) on \(event.id)")
        // TODO: 반응 토글 API 호출
        return .none
        
      // API 응답 처리
      case let .issueDetailsResponse(.success(details)):
        state.isLoading = false
        state.issueDetails = details
        return .none
        
      case let .issueDetailsResponse(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        print("❌ 이슈 상세 로드 실패: \(error)")
        return .none
        
      case let .timelineEventsResponse(.success(events)):
        state.timelineEvents = events
        return .none
        
      case let .timelineEventsResponse(.failure(error)):
        state.error = error.localizedDescription
        print("❌ 타임라인 이벤트 로드 실패: \(error)")
        return .none
      }
    }
  }
}

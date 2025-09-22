import SwiftUI
import Foundation

enum NotificationDetailModel {
  
  // MARK: - Issue Details
  struct IssueDetails: Equatable, Identifiable {
    let id: String
    let title: String
    let author: String
    let createdAt: String
    let isEdited: Bool
    let workTitle: String?
    let workDescription: String?
    let screenshots: [String]?
    let changes: Changes?
    let status: String?
    
    static let `default` = IssueDetails(
      id: "1",
      title: "[CI-1735] 카메라 실행화면 작업",
      author: "suseung",
      createdAt: "2개월",
      isEdited: true,
      workTitle: "카메라 실행화면 작업",
      workDescription: "카메라 실행화면 작업",
      screenshots: ["Camera", "ImagePicker"],
      changes: Changes(
        changedFiles: 15,
        additions: 815,
        deletions: 15,
        commits: 6,
        timeAgo: "2개월 전"
      ),
      status: "검토"
    )
  }
  
  // MARK: - Changes
  struct Changes: Equatable {
    let changedFiles: Int
    let additions: Int
    let deletions: Int
    let commits: Int
    let timeAgo: String
  }
  
  // MARK: - Timeline Event
  struct TimelineEvent: Equatable, Identifiable {
    let id: String
    let type: EventType
    let description: String
    let timeAgo: String
    let user: User?
    let content: String?
    let reactions: [Reaction]?
    
    enum EventType: String {
      case assigned = "assigned"
      case labeled = "labeled" 
      case comment = "comment"
      case commit = "commit"
      case merged = "merged"
      case approved = "approved"
      
      var iconName: String {
        switch self {
        case .assigned:
          return "person.circle"
        case .labeled:
          return "tag.fill"
        case .comment:
          return "bubble.left"
        case .commit:
          return "arrow.triangle.branch"
        case .merged:
          return "arrow.triangle.merge"
        case .approved:
          return "checkmark.circle.fill"
        }
      }
      
      var iconColor: Color {
        switch self {
        case .assigned:
          return .white
        case .labeled:
          return .white
        case .comment:
          return .white
        case .commit:
          return .white
        case .merged:
          return .white
        case .approved:
          return .white
        }
      }
      
      var iconBackgroundColor: Color {
        switch self {
        case .assigned:
          return .githubSecondaryText
        case .labeled:
          return .githubGreen
        case .comment:
          return .githubBlue
        case .commit:
          return .githubPurple
        case .merged:
          return .githubPurple
        case .approved:
          return .githubGreen
        }
      }
    }
  }
  
  // MARK: - User
  struct User: Equatable {
    let name: String
    let avatarUrl: String?
    let isMember: Bool
  }
  
  // MARK: - Reaction
  struct Reaction: Equatable {
    let emoji: String
    let count: Int
    let isSelected: Bool
  }
}

// MARK: - Timeline Event Extensions
extension NotificationDetailModel.TimelineEvent {
  var iconName: String {
    return type.iconName
  }
  
  var iconColor: Color {
    return type.iconColor
  }
  
  var iconBackgroundColor: Color {
    return type.iconBackgroundColor
  }
}

// MARK: - Default Timeline Events
extension [NotificationDetailModel.TimelineEvent] {
  static let `default`: Self = [
    .init(
      id: "1",
      type: .assigned,
      description: "suseung 님이 minyoung-cho에게 검토를 요청했습니다.",
      timeAgo: "2개월 전",
      user: nil,
      content: nil,
      reactions: nil
    ),
    .init(
      id: "2", 
      type: .assigned,
      description: "suseung 님이 이것을 자체 할당했습니다.",
      timeAgo: "2개월 전",
      user: nil,
      content: nil,
      reactions: nil
    ),
    .init(
      id: "3",
      type: .labeled,
      description: "suseung 님이 작업 레이블을 추가했습니다.",
      timeAgo: "2개월 전",
      user: nil,
      content: nil,
      reactions: nil
    ),
    .init(
      id: "4",
      type: .approved,
      description: "minyoung-cho 님이 변경 사항을 승인했습니다",
      timeAgo: "1개월 전",
      user: nil,
      content: nil,
      reactions: nil
    ),
    .init(
      id: "5",
      type: .comment,
      description: "",
      timeAgo: "1개월 전",
      user: NotificationDetailModel.User(
        name: "minyoung-cho",
        avatarUrl: nil,
        isMember: true
      ),
      content: "수고하셨습니다",
      reactions: [
        NotificationDetailModel.Reaction(emoji: "👍", count: 1, isSelected: false)
      ]
    ),
    .init(
      id: "6",
      type: .commit,
      description: "suseung 님이 b8fe67a 커밋을 epic/image-translation 에 병합했습니다.",
      timeAgo: "1개월 전",
      user: nil,
      content: nil,
      reactions: nil
    ),
    .init(
      id: "7",
      type: .commit,
      description: "suseung 님이 feat/CI-1735/camera-start 분기를 삭제했습니다.",
      timeAgo: "1개월 전",
      user: nil,
      content: nil,
      reactions: nil
    )
  ]
}

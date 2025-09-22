import SwiftUI
import ComposableArchitecture

enum NotificationDetailPage {
  struct RootView: View {
    @Bindable var store: StoreOf<NotificationDetailReducer>
    
    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          // 리포지토리 헤더
          RepositoryHeader(
            repository: store.notification.repository,
            issueNumber: store.notification.issueNumber ?? ""
          )
          
          // 이슈 제목
          IssueTitle(title: store.issueDetails?.title ?? store.notification.title)
          
          // 작성자 정보
          AuthorInfo(
            author: store.issueDetails?.author ?? "suseung",
            createdAt: store.issueDetails?.createdAt ?? "2개월",
            isEdited: store.issueDetails?.isEdited ?? true
          )
          
          // 작업명 섹션
          if let workTitle = store.issueDetails?.workTitle {
            WorkTitleSection(title: workTitle)
          }
          
          // 작업상세 섹션
          if let workDescription = store.issueDetails?.workDescription {
            WorkDetailSection(description: workDescription)
          }
          
          // 스크린샷 섹션
          if let screenshots = store.issueDetails?.screenshots, !screenshots.isEmpty {
            ScreenshotSection(screenshots: screenshots)
          }
          
          // 변경 내용 섹션
          if let changes = store.issueDetails?.changes {
            ChangesSection(changes: changes)
          }
          
          // 상태 섹션
          if let status = store.issueDetails?.status {
            StatusSection(status: status)
          }
          
          // 타임라인 이벤트들
          TimelineSection(
            events: store.timelineEvents,
            onEventTapped: { event in
              store.send(.timelineEventTapped(event))
            }
          )
        }
      }
      .background(Color.githubBackground)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button {
            store.send(.shareButtonTapped)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .foregroundColor(.githubPrimaryText)
          }
          
          Button {
            store.send(.moreButtonTapped)
          } label: {
            Image(systemName: "ellipsis")
              .foregroundColor(.githubPrimaryText)
          }
        }
      }
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
  
  // MARK: - Repository Header
  private struct RepositoryHeader: View {
    let repository: String
    let issueNumber: String
    
    var body: some View {
      HStack(spacing: GitHubSpacing.sm) {
        Image(systemName: "folder")
          .font(.system(size: 16))
          .foregroundColor(.githubBlue)
        
        Text(repository)
          .font(.githubCallout)
          .foregroundColor(.githubBlue)
        
        Text(issueNumber)
          .font(.githubCallout)
          .foregroundColor(.githubBlue)
        
        Spacer()
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.vertical, GitHubSpacing.sm)
    }
  }
  
  // MARK: - Issue Title
  private struct IssueTitle: View {
    let title: String
    
    var body: some View {
      Text(title)
        .font(.githubTitle2)
        .fontWeight(.semibold)
        .foregroundColor(.githubPrimaryText)
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.bottom, GitHubSpacing.md)
    }
  }
  
  // MARK: - Author Info
  private struct AuthorInfo: View {
    let author: String
    let createdAt: String
    let isEdited: Bool
    
    var body: some View {
      HStack(spacing: GitHubSpacing.sm) {
        // 병합 아이콘
        Image(systemName: "arrow.triangle.merge")
          .font(.system(size: 14))
          .foregroundColor(.githubPurple)
          .frame(width: 20, height: 20)
        
        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 4) {
            Text(author)
              .font(.githubCallout)
              .fontWeight(.medium)
              .foregroundColor(.githubPrimaryText)
            
            Text("님이")
              .font(.githubCallout)
              .foregroundColor(.githubPrimaryText)
            
            if isEdited {
              Text("이것을 자체 할당했습니다.")
                .font(.githubCallout)
                .foregroundColor(.githubPrimaryText)
            }
          }
          
          HStack(spacing: 4) {
            Text(author)
              .font(.githubCallout)
              .foregroundColor(.githubPrimaryText)
            
            Text("님이")
              .font(.githubCallout)
              .foregroundColor(.githubPrimaryText)
            
            Text("작업")
              .font(.githubCallout)
              .foregroundColor(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.githubGreen)
              .cornerRadius(4)
            
            Text("레이블을 추가했습니다.")
              .font(.githubCallout)
              .foregroundColor(.githubPrimaryText)
          }
        }
        
        Spacer()
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.md)
    }
  }
  
  // MARK: - Work Title Section
  private struct WorkTitleSection: View {
    let title: String
    
    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        Text("작업명")
          .font(.githubHeadline)
          .fontWeight(.semibold)
          .foregroundColor(.githubPrimaryText)
        
        Text(title)
          .font(.githubCallout)
          .foregroundColor(.githubPrimaryText)
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.lg)
    }
  }
  
  // MARK: - Work Detail Section
  private struct WorkDetailSection: View {
    let description: String
    
    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        Text("작업상세")
          .font(.githubHeadline)
          .fontWeight(.semibold)
          .foregroundColor(.githubPrimaryText)
        
        Text(description)
          .font(.githubCallout)
          .foregroundColor(.githubPrimaryText)
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.lg)
    }
  }
  
  // MARK: - Screenshot Section
  private struct ScreenshotSection: View {
    let screenshots: [String]
    
    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        Text("스크린샷")
          .font(.githubHeadline)
          .fontWeight(.semibold)
          .foregroundColor(.githubPrimaryText)
        
        HStack(spacing: GitHubSpacing.sm) {
          ForEach(screenshots, id: \.self) { screenshot in
            Rectangle()
              .fill(Color.githubSecondaryBackground)
              .frame(width: 60, height: 60)
              .cornerRadius(GitHubCornerRadius.small)
              .overlay(
                Text(screenshot)
                  .font(.githubCaption)
                  .foregroundColor(.githubSecondaryText)
              )
          }
          
          Button {
            // 더 보기 액션
          } label: {
            VStack(spacing: 4) {
              Image(systemName: "arrow.down")
                .font(.system(size: 12))
                .foregroundColor(.githubSecondaryText)
              
              Text("더 보기")
                .font(.githubCaption)
                .foregroundColor(.githubSecondaryText)
            }
            .frame(width: 60, height: 60)
            .background(Color.githubSecondaryBackground)
            .cornerRadius(GitHubCornerRadius.small)
          }
          
          Spacer()
        }
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.lg)
    }
  }
  
  // MARK: - Changes Section
  private struct ChangesSection: View {
    let changes: NotificationDetailModel.Changes
    
    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        Text("변경 내용")
          .font(.githubHeadline)
          .fontWeight(.semibold)
          .foregroundColor(.githubPrimaryText)
        
        HStack {
          HStack(spacing: GitHubSpacing.xs) {
            Image(systemName: "doc.text")
              .font(.system(size: 14))
              .foregroundColor(.githubSecondaryText)
            
            Text("변경된 파일 \(changes.changedFiles)개")
              .font(.githubCallout)
              .foregroundColor(.githubPrimaryText)
          }
          
          Spacer()
          
          HStack(spacing: GitHubSpacing.xs) {
            Text("+\(changes.additions)")
              .font(.githubCallout)
              .foregroundColor(.githubGreen)
            
            Text("-\(changes.deletions)")
              .font(.githubCallout)
              .foregroundColor(.githubRed)
            
            Image(systemName: "chevron.right")
              .font(.system(size: 12))
              .foregroundColor(.githubSecondaryText)
          }
        }
        
        HStack(spacing: GitHubSpacing.xs) {
          Image(systemName: "link")
            .font(.system(size: 14))
            .foregroundColor(.githubSecondaryText)
          
          Text("커밋 \(changes.commits)개")
            .font(.githubCallout)
            .foregroundColor(.githubPrimaryText)
          
          Spacer()
          
          Text("\(changes.timeAgo)")
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
          
          Image(systemName: "chevron.right")
            .font(.system(size: 12))
            .foregroundColor(.githubSecondaryText)
        }
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.lg)
    }
  }
  
  // MARK: - Status Section
  private struct StatusSection: View {
    let status: String
    
    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        Text("상태")
          .font(.githubHeadline)
          .fontWeight(.semibold)
          .foregroundColor(.githubPrimaryText)
        
        HStack(spacing: GitHubSpacing.sm) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.githubGreen)
          
          Text(status)
            .font(.githubCallout)
            .foregroundColor(.githubPrimaryText)
          
          Spacer()
          
          Image(systemName: "chevron.up")
            .font(.system(size: 12))
            .foregroundColor(.githubSecondaryText)
        }
      }
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.bottom, GitHubSpacing.lg)
    }
  }
  
  // MARK: - Timeline Section
  private struct TimelineSection: View {
    let events: [NotificationDetailModel.TimelineEvent]
    let onEventTapped: (NotificationDetailModel.TimelineEvent) -> Void
    
    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(events) { event in
          TimelineEventRow(
            event: event,
            onTapped: { onEventTapped(event) }
          )
        }
      }
    }
  }
  
  // MARK: - Timeline Event Row
  private struct TimelineEventRow: View {
    let event: NotificationDetailModel.TimelineEvent
    let onTapped: () -> Void
    
    var body: some View {
      Button(action: onTapped) {
        HStack(alignment: .top, spacing: GitHubSpacing.md) {
          // 타임라인 아이콘
          ZStack {
            Circle()
              .fill(event.iconBackgroundColor)
              .frame(width: 32, height: 32)
            
            Image(systemName: event.iconName)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(event.iconColor)
          }
          
          // 이벤트 내용
          VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
            if let user = event.user {
              // 사용자 댓글
              VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
                HStack(spacing: GitHubSpacing.xs) {
                  Text(user.name)
                    .font(.githubCallout)
                    .fontWeight(.medium)
                    .foregroundColor(.githubPrimaryText)
                  
                  Text("• \(event.timeAgo)")
                    .font(.githubCaption)
                    .foregroundColor(.githubSecondaryText)
                  
                  if user.isMember {
                    Text("멤버")
                      .font(.githubCaption)
                      .foregroundColor(.githubSecondaryText)
                      .padding(.horizontal, 6)
                      .padding(.vertical, 2)
                      .background(Color.githubSecondaryBackground)
                      .cornerRadius(4)
                  }
                  
                  Spacer()
                }
                
                if let content = event.content {
                  Text(content)
                    .font(.githubCallout)
                    .foregroundColor(.githubPrimaryText)
                    .multilineTextAlignment(.leading)
                }
                
                // 반응 버튼들
                if let reactions = event.reactions, !reactions.isEmpty {
                  HStack(spacing: GitHubSpacing.xs) {
                    ForEach(reactions, id: \.emoji) { reaction in
                      Button {
                        // 반응 토글
                      } label: {
                        HStack(spacing: 4) {
                          Text(reaction.emoji)
                            .font(.system(size: 14))
                          
                          if reaction.count > 0 {
                            Text("\(reaction.count)")
                              .font(.githubCaption)
                              .foregroundColor(.githubSecondaryText)
                          }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.githubSecondaryBackground)
                        .cornerRadius(16)
                      }
                    }
                    
                    Spacer()
                  }
                }
              }
              .padding(.all, GitHubSpacing.md)
              .background(Color.githubCardBackground)
              .cornerRadius(GitHubCornerRadius.medium)
            } else {
              // 시스템 이벤트
              Text(event.description)
                .font(.githubCallout)
                .foregroundColor(.githubPrimaryText)
            }
          }
          
          Spacer()
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.bottom, GitHubSpacing.md)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}

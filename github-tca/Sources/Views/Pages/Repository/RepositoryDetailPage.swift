import SwiftUI
import ComposableArchitecture

enum RepositoryDetailPage {
  struct RootView: View {
    @Bindable var store: StoreOf<RepositoryDetailReducer>
    
    var body: some View {
      ScrollView {
        VStack(alignment: .leading, spacing: GitHubSpacing.lg) {
          // 리포지토리 헤더
          RepositoryHeader(
            repository: store.repository
          )
          
          // 리포지토리 액션 버튼들
          RepositoryActionButtons(
            isStarred: store.isStarred,
            isWatching: store.isWatching,
            onStarTapped: { store.send(.starTapped) },
            onWatchTapped: { store.send(.watchTapped) },
            onForkTapped: { store.send(.forkTapped) }
          )
          
          // 리포지토리 정보
          RepositoryInfo(repository: store.repository)
          
          // 리포지토리 통계
          RepositoryStats(repository: store.repository)
          
          // 네비게이션 섹션
          RepositoryNavigationSection(
            onIssuesTapped: { store.send(.issuesTapped) },
            onPullRequestsTapped: { store.send(.pullRequestsTapped) },
            onContributorsTapped: { store.send(.contributorsTapped) },
            onBranchesTapped: { store.send(.branchesTapped) }
          )
          
          // README 섹션
          ReadmeSection(
            readmeContent: store.readmeContent,
            isLoadingReadme: store.isLoadingReadme,
            readmeError: store.readmeError,
            onRetryTapped: { store.send(.loadReadme) }
          )
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .background(Color.githubBackground)
      .navigationTitle(store.repository.name)
      .navigationBarTitleDisplayMode(.large)
      .githubNavigationStyle()
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button {
            store.send(.shareTapped)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .foregroundColor(.githubPrimaryText)
          }
          
          Menu {
            Button {
              store.send(.openInBrowser)
            } label: {
              Label("브라우저에서 열기", systemImage: "safari")
            }
            
            Button {
              store.send(.copyURL)
            } label: {
              Label("URL 복사", systemImage: "doc.on.doc")
            }
          } label: {
            Image(systemName: "ellipsis.circle")
              .foregroundColor(.githubPrimaryText)
          }
        }
      }
      .onAppear {
        store.send(.onAppear)
      }
      .refreshable {
        store.send(.refreshRepository)
      }
    }
  }

   // MARK: - Repository Header
   private struct RepositoryHeader: View {
     let repository: ProfileModel.RepositoryItem
 
     var body: some View {
       VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
         // 리포지토리 이름과 소유자
         HStack {
           VStack(alignment: .leading, spacing: 4) {
             Text(repository.fullName.components(separatedBy: "/").first ?? "")
               .font(.githubFootnote)
               .foregroundColor(.githubSecondaryText)
 
             Text(repository.name)
               .font(.githubTitle2)
               .foregroundColor(.githubPrimaryText)
           }
 
           Spacer()
 
           // 언어 표시
           if let language = repository.language, !language.isEmpty {
             HStack(spacing: 4) {
               Circle()
                 .fill(repository.languageColor ?? .githubTertiaryText)
                 .frame(width: 12, height: 12)
 
               Text(language)
                 .font(.githubFootnote)
                 .foregroundColor(.githubSecondaryText)
             }
           }
         }
 
         // 설명
         if let description = repository.description, !description.isEmpty {
           Text(description)
             .font(.githubBody)
             .foregroundColor(.githubSecondaryText)
             .lineLimit(nil)
         }
       }
       .padding(GitHubSpacing.md)
       .background(Color.githubCardBackground)
       .cornerRadius(GitHubCornerRadius.card)
     }
   }

   // MARK: - Repository Action Buttons
   private struct RepositoryActionButtons: View {
     let isStarred: Bool
     let isWatching: Bool
     let onStarTapped: () -> Void
     let onWatchTapped: () -> Void
     let onForkTapped: () -> Void
 
     var body: some View {
       HStack(spacing: GitHubSpacing.md) {
         // Star 버튼
         Button(action: { onStarTapped() }) {
           HStack(spacing: 4) {
             Image(systemName: isStarred ? "star.fill" : "star")
             Text(isStarred ? "Starred" : "Star")
               .font(.githubCallout)
           }
           .foregroundColor(isStarred ? .white : .githubPrimaryText)
           .padding(.horizontal, GitHubSpacing.md)
           .padding(.vertical, GitHubSpacing.sm)
           .background(isStarred ? Color.githubBlue : Color.githubCardBackground)
           .cornerRadius(GitHubCornerRadius.button)
         }
 
         // Watch 버튼
         Button(action: { onWatchTapped() }) {
           HStack(spacing: 4) {
             Image(systemName: isWatching ? "eye.fill" : "eye")
             Text(isWatching ? "Watching" : "Watch")
               .font(.githubCallout)
           }
           .foregroundColor(isWatching ? .white : .githubPrimaryText)
           .padding(.horizontal, GitHubSpacing.md)
           .padding(.vertical, GitHubSpacing.sm)
           .background(isWatching ? Color.githubBlue : Color.githubCardBackground)
           .cornerRadius(GitHubCornerRadius.button)
         }
 
         // Fork 버튼
         Button(action: { onForkTapped() }) {
           HStack(spacing: 4) {
             Image(systemName: "tuningfork")
             Text("Fork")
               .font(.githubCallout)
           }
           .foregroundColor(.githubPrimaryText)
           .padding(.horizontal, GitHubSpacing.md)
           .padding(.vertical, GitHubSpacing.sm)
           .background(Color.githubCardBackground)
           .cornerRadius(GitHubCornerRadius.button)
         }
       }
     }
   }

   // MARK: - Repository Navigation Section
   private struct RepositoryNavigationSection: View {
     let onIssuesTapped: () -> Void
     let onPullRequestsTapped: () -> Void
     let onContributorsTapped: () -> Void
     let onBranchesTapped: () -> Void
 
     var body: some View {
       VStack(spacing: GitHubSpacing.md) {
         GitHubSectionHeader("탐색")
 
         VStack(spacing: GitHubSpacing.xs) {
           NavigationRow(
             icon: "exclamationmark.circle",
             title: "Issues",
             subtitle: "버그 리포트 및 기능 요청",
             action: onIssuesTapped
           )
 
           NavigationRow(
             icon: "arrow.triangle.pull",
             title: "Pull Requests",
             subtitle: "코드 변경사항 검토",
             action: onPullRequestsTapped
           )
 
           NavigationRow(
             icon: "person.2",
             title: "Contributors",
             subtitle: "기여자 목록",
             action: onContributorsTapped
           )
 
           NavigationRow(
             icon: "point.3.connected.trianglepath.dotted",
             title: "Branches",
             subtitle: "브랜치 및 태그",
             action: onBranchesTapped
           )
         }
       }
     }
   }

  private struct NavigationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack {
          Image(systemName: icon)
            .foregroundColor(.githubSecondaryText)
            .frame(width: 24)

          VStack(alignment: .leading, spacing: 2) {
             Text(title)
               .font(.githubCallout)
               .foregroundColor(.githubPrimaryText)

             Text(subtitle)
               .font(.githubFootnote)
               .foregroundColor(.githubSecondaryText)
          }

          Spacer()

          Image(systemName: "chevron.right")
            .foregroundColor(.githubTertiaryText)
            .font(.caption)
        }
         .padding(GitHubSpacing.md)
         .background(Color.githubCardBackground)
         .cornerRadius(GitHubCornerRadius.small)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  // MARK: - Repository Info
  private struct RepositoryInfo: View {
    let repository: ProfileModel.RepositoryItem

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        GitHubSectionHeader("정보")

        VStack(spacing: GitHubSpacing.sm) {
          InfoRow(icon: "star", label: "Stars", value: "\(repository.starCount)")
          InfoRow(icon: "tuningfork", label: "Forks", value: "\(repository.forkCount)")
          InfoRow(icon: "clock", label: "최근 업데이트", value: repository.updatedAt)

          if repository.isPrivate {
            InfoRow(icon: "lock", label: "접근", value: "Private")
          } else {
            InfoRow(icon: "globe", label: "접근", value: "Public")
          }
        }
      }
    }
  }

  private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
      HStack {
        Image(systemName: icon)
          .foregroundColor(.githubSecondaryText)
          .frame(width: 20)

         Text(label)
           .font(.githubCallout)
           .foregroundColor(.githubSecondaryText)

        Spacer()

         Text(value)
           .font(.githubCallout)
           .foregroundColor(.githubPrimaryText)
      }
       .padding(.horizontal, GitHubSpacing.md)
       .padding(.vertical, GitHubSpacing.sm)
       .background(Color.githubCardBackground)
       .cornerRadius(GitHubCornerRadius.small)
    }
  }

  // MARK: - Repository Stats
  private struct RepositoryStats: View {
    let repository: ProfileModel.RepositoryItem

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        GitHubSectionHeader("통계")

        HStack(spacing: GitHubSpacing.md) {
          StatCard(
            icon: "star.fill",
            title: "Stars",
            value: "\(repository.starCount)",
            color: .githubYellow
          )

          StatCard(
            icon: "tuningfork",
            title: "Forks",
            value: "\(repository.forkCount)",
            color: .githubBlue
          )

          StatCard(
            icon: "eye.fill",
            title: "Language",
            value: repository.language ?? "Unknown",
            color: .githubGreen
          )
        }
      }
    }
  }

  private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
      VStack(spacing: GitHubSpacing.xs) {
        Image(systemName: icon)
          .foregroundColor(color)
          .font(.title2)

         Text(value)
           .font(.githubTitle3)
           .foregroundColor(.githubPrimaryText)

         Text(title)
           .font(.githubFootnote)
           .foregroundColor(.githubSecondaryText)
      }
       .frame(maxWidth: .infinity)
       .padding(GitHubSpacing.md)
       .background(Color.githubCardBackground)
       .cornerRadius(GitHubCornerRadius.card)
    }
  }

   // MARK: - README Section
   private struct ReadmeSection: View {
     let readmeContent: String?
     let isLoadingReadme: Bool
     let readmeError: String?
     let onRetryTapped: () -> Void
 
     var body: some View {
       VStack(spacing: GitHubSpacing.md) {
         GitHubSectionHeader("README")
 
         VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
           if isLoadingReadme {
             HStack {
               ProgressView()
                 .scaleEffect(0.8)
               Text("README 파일을 읽어오는 중...")
                 .font(.githubCallout)
                 .foregroundColor(.githubSecondaryText)
             }
             .frame(maxWidth: .infinity, alignment: .leading)
           } else if let readmeError = readmeError {
             VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
               HStack {
                 Image(systemName: "exclamationmark.triangle")
                   .foregroundColor(.githubRed)
                 Text("README 로드 실패")
                   .font(.githubCallout)
                   .foregroundColor(.githubRed)
               }
 
               Text(readmeError)
                 .font(.githubFootnote)
                 .foregroundColor(.githubSecondaryText)
 
               Button("다시 시도") {
                 onRetryTapped()
               }
               .padding(.horizontal, GitHubSpacing.md)
               .padding(.vertical, GitHubSpacing.sm)
               .background(Color.githubCardBackground)
               .cornerRadius(GitHubCornerRadius.button)
               .foregroundColor(.githubPrimaryText)
             }
             .frame(maxWidth: .infinity, alignment: .leading)
           } else if let readmeContent = readmeContent {
             ReadmeContentView(content: readmeContent)
           } else {
             Text("README 파일이 없습니다.")
               .font(.githubCallout)
               .foregroundColor(.githubSecondaryText)
               .frame(maxWidth: .infinity, alignment: .leading)
           }
         }
         .padding(GitHubSpacing.md)
         .background(Color.githubCardBackground)
         .cornerRadius(GitHubCornerRadius.card)
       }
     }
   }

  // MARK: - README Content View
  private struct ReadmeContentView: View {
    let content: String

    var body: some View {
      VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
        // README 내용을 간단하게 표시 (실제로는 Markdown 파서가 필요)
        ForEach(content.components(separatedBy: "\n\n"), id: \.self) { paragraph in
          if paragraph.hasPrefix("# ") {
             Text(String(paragraph.dropFirst(2)))
               .font(.githubTitle2)
               .foregroundColor(.githubPrimaryText)
          } else if paragraph.hasPrefix("## ") {
             Text(String(paragraph.dropFirst(3)))
               .font(.githubTitle3)
               .foregroundColor(.githubPrimaryText)
              .padding(.top, GitHubSpacing.sm)
          } else if paragraph.hasPrefix("```") {
            CodeBlockView(code: paragraph)
          } else if !paragraph.isEmpty {
             Text(paragraph)
               .font(.githubCallout)
               .foregroundColor(.githubSecondaryText)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: - Code Block View
  private struct CodeBlockView: View {
    let code: String

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        // 코드 블록 헤더
        if code.hasPrefix("```bash") {
          HStack {
             Text("bash")
               .font(.githubFootnote)
               .foregroundColor(.githubSecondaryText)
            Spacer()
          }
          .padding(.horizontal, GitHubSpacing.sm)
          .padding(.vertical, 4)
          .background(Color.githubTertiaryBackground)
        }

        // 코드 내용
         Text(cleanCodeContent(code))
           .font(.githubMonospaced)
           .foregroundColor(.githubPrimaryText)
          .padding(GitHubSpacing.sm)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.githubSecondaryBackground)
      }
       .cornerRadius(GitHubCornerRadius.small)
       .overlay(
         RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
           .stroke(Color.githubBorder, lineWidth: 1)
       )
    }

    private func cleanCodeContent(_ code: String) -> String {
      var cleaned = code
      if cleaned.hasPrefix("```bash\n") {
        cleaned = String(cleaned.dropFirst(8))
      } else if cleaned.hasPrefix("```\n") {
        cleaned = String(cleaned.dropFirst(4))
      }
      if cleaned.hasSuffix("\n```") {
        cleaned = String(cleaned.dropLast(4))
      }
      return cleaned
    }
  }


}

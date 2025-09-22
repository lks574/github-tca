import SwiftUI
import ComposableArchitecture

enum RepositoryListPage {
  struct RootView: View {
    @Bindable var store: StoreOf<RepositoryListReducer>
    
    var body: some View {
      ScrollView {
        LazyVStack(spacing: GitHubSpacing.md) {
          // 검색 바
          SearchBarSection(
            searchText: store.searchQuery,
            isSearching: store.isSearching,
            onSearchTextChanged: { query in
              store.send(.searchQueryChanged(query))
            },
            onSearchSubmitted: {
              store.send(.searchSubmitted)
            },
            onSearchCancelled: {
              store.send(.searchCancelled)
            }
          )
          
          // 필터 섹션
          FilterSection(
            selectedFilter: store.selectedFilter,
            selectedSort: store.selectedSort,
            onFilterChanged: { filter in
              store.send(.filterChanged(filter))
            },
            onSortChanged: { sort in
              store.send(.sortChanged(sort))
            }
          )
          
          // 리포지토리 리스트
          RepositoryListSection(
            repositories: store.repositories,
            isLoading: store.isLoading,
            isLoadingMore: store.isLoadingMore,
            hasMore: store.hasMore,
            errorMessage: store.errorMessage,
            onRepositoryTapped: { repository in
              store.send(.repositoryTapped(repository))
            },
            onLoadMore: {
              store.send(.loadMore)
            },
            onRefresh: {
              store.send(.refresh)
            }
          )
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
      }
      .background(Color.githubBackground)
      .navigationTitle("리포지토리")
      .navigationBarTitleDisplayMode(.large)
      .onAppear {
        store.send(.onAppear)
      }
      .refreshable {
        store.send(.refresh)
      }
    }
  }
  
  // MARK: - Search Bar Section
  private struct SearchBarSection: View {
    let searchText: String
    let isSearching: Bool
    let onSearchTextChanged: (String) -> Void
    let onSearchSubmitted: () -> Void
    let onSearchCancelled: () -> Void
    
    var body: some View {
      HStack(spacing: GitHubSpacing.sm) {
        HStack(spacing: GitHubSpacing.sm) {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.githubSecondaryText)
            .font(.system(size: GitHubIconSize.medium))
          
          TextField("리포지토리 검색...", text: .init(
            get: { searchText },
            set: onSearchTextChanged
          ))
          .font(.githubCallout)
          .foregroundColor(.githubPrimaryText)
          .submitLabel(.search)
          .onSubmit {
            onSearchSubmitted()
          }
          
          if !searchText.isEmpty {
            Button(action: onSearchCancelled) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.githubTertiaryText)
                .font(.system(size: GitHubIconSize.medium))
            }
          }
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.sm)
        .background(Color.githubCardBackground)
        .cornerRadius(GitHubCornerRadius.medium)
      }
    }
  }
  
  // MARK: - Filter Section
  private struct FilterSection: View {
    let selectedFilter: RepositoryFilter
    let selectedSort: RepositorySort
    let onFilterChanged: (RepositoryFilter) -> Void
    let onSortChanged: (RepositorySort) -> Void
    
    var body: some View {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: GitHubSpacing.sm) {
          // 필터 버튼들
          ForEach(RepositoryFilter.allCases, id: \.self) { filter in
            FilterButton(
              title: filter.displayName,
              isSelected: selectedFilter == filter,
              action: { onFilterChanged(filter) }
            )
          }
          
          Divider()
            .frame(height: 20)
          
          // 정렬 버튼들
          ForEach(RepositorySort.allCases, id: \.self) { sort in
            FilterButton(
              title: sort.displayName,
              isSelected: selectedSort == sort,
              action: { onSortChanged(sort) }
            )
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
      }
    }
  }
  
  // MARK: - Filter Button
  private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
      Button(action: action) {
        Text(title)
          .font(.githubSubheadline)
          .foregroundColor(isSelected ? .white : .githubSecondaryText)
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.xs)
          .background(isSelected ? Color.githubBlue : Color.githubCardBackground)
          .cornerRadius(GitHubCornerRadius.large)
      }
    }
  }
  
  // MARK: - Repository List Section
  private struct RepositoryListSection: View {
    let repositories: [ProfileModel.RepositoryItem]
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMore: Bool
    let errorMessage: String?
    let onRepositoryTapped: (ProfileModel.RepositoryItem) -> Void
    let onLoadMore: () -> Void
    let onRefresh: () -> Void
    
    var body: some View {
      LazyVStack(spacing: GitHubSpacing.sm) {
        if isLoading && repositories.isEmpty {
          // 초기 로딩
          LoadingView()
        } else if repositories.isEmpty && !isLoading {
          // 빈 상태
          EmptyStateView()
        } else {
          // 리포지토리 카드들
          ForEach(repositories) { repository in
            RepositoryListItem(
              repository: repository,
              onTap: { onRepositoryTapped(repository) }
            )
          }
          
          // 더 로드하기 버튼
          if hasMore {
            LoadMoreButton(
              isLoading: isLoadingMore,
              onTap: onLoadMore
            )
          }
        }
        
        // 에러 메시지
        if let errorMessage = errorMessage {
          GitHubErrorComponents.InlineErrorView(
            errorMessage: errorMessage,
            canRetry: true,
            onRetry: onRefresh,
            onDismiss: nil
          )
        }
      }
    }
  }
  
  // MARK: - Repository List Item
  private struct RepositoryListItem: View {
    let repository: ProfileModel.RepositoryItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
          // 헤더 (소유자 정보)
          HStack {
            HStack(spacing: GitHubSpacing.xs) {
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: GitHubIconSize.small))
                .foregroundColor(.githubSecondaryText)
              
              Text(repository.fullName.components(separatedBy: "/").first ?? "")
                .font(.githubFootnote)
                .foregroundColor(.githubSecondaryText)
            }
            
            Spacer()
            
            // Private/Public 배지
            if repository.isPrivate {
              Text("Private")
                .font(.githubCaption)
                .foregroundColor(.githubSecondaryText)
                .padding(.horizontal, GitHubSpacing.xs)
                .padding(.vertical, 2)
                .background(
                  RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
                    .stroke(Color.githubBorder, lineWidth: 1)
                )
            }
          }
          
          // 리포지토리 이름
          Text(repository.name)
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          // 설명
          if let description = repository.description, !description.isEmpty {
            Text(description)
              .font(.githubCallout)
              .foregroundColor(.githubSecondaryText)
              .lineLimit(2)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          
          // 메타 정보 (언어, 스타, 업데이트 시간)
          HStack(spacing: GitHubSpacing.md) {
            // 언어
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
            
            // 스타 수
            HStack(spacing: 4) {
              Image(systemName: "star")
                .font(.system(size: GitHubIconSize.small))
                .foregroundColor(.githubSecondaryText)
              
              Text("\(repository.starCount)")
                .font(.githubFootnote)
                .foregroundColor(.githubSecondaryText)
            }
            
            // 포크 수
            if repository.forkCount > 0 {
              HStack(spacing: 4) {
                Image(systemName: "tuningfork")
                  .font(.system(size: GitHubIconSize.small))
                  .foregroundColor(.githubSecondaryText)
                
                Text("\(repository.forkCount)")
                  .font(.githubFootnote)
                  .foregroundColor(.githubSecondaryText)
              }
            }
            
            Spacer()
            
            // 업데이트 시간
            Text(repository.updatedAt)
              .font(.githubCaption)
              .foregroundColor(.githubTertiaryText)
          }
        }
        .padding(GitHubSpacing.md)
        .background(Color.githubCardBackground)
        .cornerRadius(GitHubCornerRadius.card)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - Loading View
  private struct LoadingView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        ProgressView()
          .scaleEffect(1.2)
        
        Text("리포지토리를 불러오는 중...")
          .font(.githubCallout)
          .foregroundColor(.githubSecondaryText)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, GitHubSpacing.xl)
    }
  }
  
  // MARK: - Empty State View
  private struct EmptyStateView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Image(systemName: "folder")
          .font(.system(size: 60))
          .foregroundColor(.githubTertiaryText)
        
        VStack(spacing: GitHubSpacing.sm) {
          Text("리포지토리가 없습니다")
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
          
          Text("아직 생성된 리포지토리가 없습니다.\n새로운 프로젝트를 시작해보세요!")
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .multilineTextAlignment(.center)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, GitHubSpacing.xxxl)
    }
  }
  
  // MARK: - Load More Button
  private struct LoadMoreButton: View {
    let isLoading: Bool
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.sm) {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
          }
          
          Text(isLoading ? "로딩 중..." : "더 보기")
            .font(.githubCallout)
        }
        .foregroundColor(.githubBlue)
        .frame(maxWidth: .infinity)
        .padding(.vertical, GitHubSpacing.md)
        .background(Color.githubCardBackground)
        .cornerRadius(GitHubCornerRadius.medium)
      }
      .disabled(isLoading)
    }
  }
  
}

// MARK: - Repository Filter
enum RepositoryFilter: String, CaseIterable {
  case all = "all"
  case owned = "owner"
  case member = "member"
  case `public` = "public"
  case `private` = "private"
  case forked = "forked"
  
  var displayName: String {
    switch self {
    case .all: return "전체"
    case .owned: return "소유"
    case .member: return "멤버"
    case .public: return "공개"
    case .private: return "비공개"
    case .forked: return "포크"
    }
  }
}

// MARK: - Repository Sort
enum RepositorySort: String, CaseIterable {
  case updated = "updated"
  case created = "created"
  case pushed = "pushed"
  case name = "full_name"
  case stars = "stargazers_count"
  
  var displayName: String {
    switch self {
    case .updated: return "최근 업데이트"
    case .created: return "생성일"
    case .pushed: return "최근 푸시"
    case .name: return "이름"
    case .stars: return "스타"
    }
  }
}


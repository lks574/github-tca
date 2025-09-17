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
          // 검색바 섹션
          VStack(spacing: GitHubSpacing.md) {
            SearchBarSection(
              searchQuery: $store.searchQuery,
              searchResultsText: store.searchResultsText,
              showingSearchResults: store.showingSearchResults,
              onSearchSubmitted: { store.send(.searchSubmitted) },
              onSearchQueryChanged: { store.send(.searchQueryChanged($0)) },
              onClearSearch: { store.send(.clearSearch) },
              onSearchCancelled: { store.send(.searchCancelled) }
            )

            // 카테고리 필터
            CategoryFilterSection(
              categories: ExploreReducer.SearchCategory.allCases,
              selectedCategory: store.selectedCategory,
              onCategorySelected: { store.send(.categorySelected($0)) }
            )
          }

          // 검색 결과 또는 기본 컨텐츠
          if store.showingSearchResults {
            SearchResultsSection(
              isSearching: store.isSearching,
              shouldShowError: store.shouldShowError,
              searchError: store.searchError,
              shouldShowEmptyState: store.shouldShowEmptyState,
              searchResults: store.searchResults,
              canLoadMore: store.canLoadMore,
              isLoadingMore: store.isLoadingMore,
              onRepositoryTapped: { store.send(.repositoryTapped($0)) },
              onRefreshSearch: { store.send(.refreshSearch) },
              onLoadMore: { store.send(.loadMore) }
            )
          } else {
            DefaultContentSections(
              searchItems: store.searchItems,
              activityItems: store.activityItems,
              popularRepositories: store.popularRepositories,
              onSearchItemTapped: { store.send(.searchItemTapped($0)) },
              onActivityItemTapped: { store.send(.activityItemTapped($0)) },
              onRepositoryTapped: { store.send(.repositoryTapped($0)) }
            )
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .background(Color.githubBackground)
      .navigationTitle("탐색")
      .githubNavigationStyle()
      .onAppear {
        store.send(.onAppear)
      }
    }
  }

  // MARK: - Search Bar Section
  private struct SearchBarSection: View {
    @Binding var searchQuery: String
    let searchResultsText: String
    let showingSearchResults: Bool
    let onSearchSubmitted: () -> Void
    let onSearchQueryChanged: (String) -> Void
    let onClearSearch: () -> Void
    let onSearchCancelled: () -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.sm) {
        HStack(spacing: GitHubSpacing.sm) {
          HStack(spacing: GitHubSpacing.sm) {
            Image(systemName: "magnifyingglass")
              .font(.system(size: GitHubIconSize.small))
              .foregroundColor(.githubTertiaryText)

            TextField("레포지토리 검색...", text: $searchQuery)
              .textFieldStyle(PlainTextFieldStyle())
              .submitLabel(.search)
              .githubStyle(GitHubTextStyle.primaryText)
              .onSubmit {
                onSearchSubmitted()
              }
              .onChange(of: searchQuery) { _, newValue in
                onSearchQueryChanged(newValue)
              }

            if !searchQuery.isEmpty {
              Button {
                onClearSearch()
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: GitHubIconSize.small))
                  .foregroundColor(.githubTertiaryText)
              }
            }
          }
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.sm)
          .background(Color.githubCardBackground)
          .cornerRadius(GitHubCornerRadius.medium)
          .overlay(
            RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
              .stroke(Color.githubBorder, lineWidth: 1)
          )

          if showingSearchResults {
            Button {
              onSearchCancelled()
            } label: {
              Text("취소")
                .githubStyle(GitHubTextStyle.linkText)
            }
          }
        }

        // 검색 결과 정보
        if !searchResultsText.isEmpty {
          HStack {
            Text(searchResultsText)
              .githubStyle(GitHubTextStyle.captionText)
            Spacer()
          }
        }
      }
    }
  }

  // MARK: - Category Filter Section
  private struct CategoryFilterSection: View {
    let categories: [ExploreReducer.SearchCategory]
    let selectedCategory: ExploreReducer.SearchCategory
    let onCategorySelected: (ExploreReducer.SearchCategory) -> Void

    var body: some View {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: GitHubSpacing.sm) {
          ForEach(categories, id: \.rawValue) { category in
            CategoryFilterChip(
              category: category,
              isSelected: selectedCategory == category
            ) {
              onCategorySelected(category)
            }
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
      }
      .padding(.horizontal, -GitHubSpacing.screenPadding)
    }
  }

  // MARK: - Category Filter Chip
  private struct CategoryFilterChip: View {
    let category: ExploreReducer.SearchCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
      Button(action: onTap) {
        Text(category.rawValue)
          .font(.githubCaption)
          .fontWeight(.medium)
          .foregroundColor(isSelected ? .white : .githubSecondaryText)
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.xs)
          .background(
            RoundedRectangle(cornerRadius: GitHubCornerRadius.large)
              .fill(isSelected ? Color.githubAccent : Color.githubCardBackground)
          )
          .overlay(
            RoundedRectangle(cornerRadius: GitHubCornerRadius.large)
              .stroke(isSelected ? Color.clear : Color.githubBorder, lineWidth: 1)
          )
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  // MARK: - Search Results Section
  private struct SearchResultsSection: View {
    let isSearching: Bool
    let shouldShowError: Bool
    let searchError: String?
    let shouldShowEmptyState: Bool
    let searchResults: [ExploreModel.PopularRepository]
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let onRepositoryTapped: (ExploreModel.PopularRepository) -> Void
    let onRefreshSearch: () -> Void
    let onLoadMore: () -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        if isSearching {
          LoadingView()
        } else if shouldShowError {
          ErrorView(message: searchError ?? "오류가 발생했습니다.") {
            onRefreshSearch()
          }
        } else if shouldShowEmptyState {
          EmptySearchView()
        } else {
          LazyVStack(spacing: GitHubSpacing.sm) {
            ForEach(searchResults) { repository in
              SearchResultCard(repository: repository) {
                onRepositoryTapped(repository)
              }
            }

            // 더 로드하기 버튼
            if canLoadMore {
              LoadMoreButton(isLoading: isLoadingMore) {
                onLoadMore()
              }
            }
          }
        }
      }
    }
  }

  // MARK: - Default Content Sections
  private struct DefaultContentSections: View {
    let searchItems: [ExploreModel.SearchItem]
    let activityItems: [ExploreModel.ActivityItem]
    let popularRepositories: [ExploreModel.PopularRepository]
    let onSearchItemTapped: (ExploreModel.SearchItem) -> Void
    let onActivityItemTapped: (ExploreModel.ActivityItem) -> Void
    let onRepositoryTapped: (ExploreModel.PopularRepository) -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        // 검색 섹션
        VStack(spacing: GitHubSpacing.md) {
          GitHubSectionHeader("검색")

          LazyVStack(spacing: GitHubSpacing.sm) {
            ForEach(searchItems) { item in
              ExploreSearchItem(item: item) {
                onSearchItemTapped(item)
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
            ForEach(activityItems) { activity in
              ExploreActivityItem(activity: activity) {
                onActivityItemTapped(activity)
              }
            }

            ForEach(popularRepositories) { repository in
              ExploreRepositoryCard(repository: repository) {
                onRepositoryTapped(repository)
              }
            }
          }
        }
      }
    }
  }

  // MARK: - Search Result Card
  private struct SearchResultCard: View {
    let repository: ExploreModel.PopularRepository
    let onTap: () -> Void

    var body: some View {
      Button(action: onTap) {
        GitHubCard {
          VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
            // 헤더
            HStack(spacing: GitHubSpacing.sm) {
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: GitHubIconSize.medium))
                .foregroundColor(.githubSecondaryText)

              VStack(alignment: .leading, spacing: 2) {
                Text(repository.fullName)
                  .githubStyle(GitHubTextStyle.primaryText)
                  .fontWeight(.medium)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Text("@\(repository.owner)")
                  .githubStyle(GitHubTextStyle.captionText)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }

              Spacer()

              VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: GitHubSpacing.xxs) {
                  Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.githubYellow)

                  Text("\(repository.stars.formatted())")
                    .githubStyle(GitHubTextStyle.captionText)
                }

                Text(repository.lastUpdate)
                  .githubStyle(GitHubTextStyle.captionText)
              }
            }

            // 설명
            if !repository.description.isEmpty {
              Text(repository.description)
                .githubStyle(GitHubTextStyle.secondaryText)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 하단 정보
            HStack(spacing: GitHubSpacing.md) {
              if !repository.language.isEmpty && repository.language != "Unknown" {
                HStack(spacing: GitHubSpacing.xxs) {
                  Circle()
                    .fill(Color.githubBlue)
                    .frame(width: 12, height: 12)

                  Text(repository.language)
                    .githubStyle(GitHubTextStyle.captionText)
                }
              }

              if repository.isReleased {
                HStack(spacing: GitHubSpacing.xxs) {
                  Image(systemName: "tag.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.githubGreen)

                  Text("최신 릴리스")
                    .githubStyle(GitHubTextStyle.captionText)
                }
              }

              Spacer()
            }
          }
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.md)
        }
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

        Text("검색 중...")
          .githubStyle(GitHubTextStyle.secondaryText)
      }
      .padding(.vertical, GitHubSpacing.xl)
    }
  }

  // MARK: - Error View
  private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: GitHubIconSize.large))
          .foregroundColor(.githubRed)

        Text(message)
          .githubStyle(GitHubTextStyle.secondaryText)
          .multilineTextAlignment(.center)

        Button("다시 시도", action: onRetry)
          .githubButtonStyle(.secondary)
      }
      .padding(.vertical, GitHubSpacing.xl)
    }
  }

  // MARK: - Empty Search View
  private struct EmptySearchView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: GitHubIconSize.large))
          .foregroundColor(.githubTertiaryText)

        VStack(spacing: GitHubSpacing.xs) {
          Text("검색 결과 없음")
            .githubStyle(GitHubTextStyle.primaryText)
            .fontWeight(.medium)

          Text("다른 검색어를 시도해보세요")
            .githubStyle(GitHubTextStyle.secondaryText)
        }
      }
      .padding(.vertical, GitHubSpacing.xl)
    }
  }

  // MARK: - Load More Button
  private struct LoadMoreButton: View {
    let isLoading: Bool
    let onTap: () -> Void

    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.xs) {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)

            Text("로딩 중...")
              .githubStyle(GitHubTextStyle.secondaryText)
          } else {
            Text("더 보기")
              .githubStyle(GitHubTextStyle.linkText)
              .fontWeight(.medium)
          }
        }
        .padding(.vertical, GitHubSpacing.md)
      }
      .disabled(isLoading)
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
            .githubStyle(GitHubTextStyle.primaryText)
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
                  .githubStyle(GitHubTextStyle.primaryText)
                  .fontWeight(.medium)

                Text(activity.timeAgo)
                  .githubStyle(GitHubTextStyle.captionText)

                Spacer()
              }

              Text(activity.action)
                .githubStyle(GitHubTextStyle.secondaryText)
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
                  .githubStyle(GitHubTextStyle.primaryText)
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
                  .githubStyle(GitHubTextStyle.secondaryText)
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

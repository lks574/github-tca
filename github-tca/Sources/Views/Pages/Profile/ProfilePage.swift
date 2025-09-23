import SwiftUI
import ComposableArchitecture

enum ProfilePage {
  struct RootView: View {
    @Bindable var store: StoreOf<ProfileReducer>
    
    var body: some View {
      Group {
        if store.isInitialLoading {
          // 초기 로딩 화면
          initialLoadingView
        } else if store.isAuthenticated {
          // 인증된 사용자 프로필
          authenticatedProfileView
        } else {
          // 로그인 화면
          loginView
        }
      }
      .background(Color.githubBackground)
      .navigationTitle("프로필")
      .githubNavigationStyle()
      .onAppear {
        store.send(.loadProfile)
      }
      .refreshable {
        store.send(.refreshProfile)
      }
      .alert("로그아웃", isPresented: $store.showingSignOutAlert) {
        Button("취소", role: .cancel) {
          store.send(.signOutCancelled)
        }
        Button("로그아웃", role: .destructive) {
          store.send(.signOutConfirmed)
        }
      } message: {
        Text("정말 로그아웃하시겠습니까?")
      }
      .alert("오류", isPresented: .constant(store.errorMessage != nil)) {
        Button("확인") {
          store.send(.binding(.set(\.errorMessage, nil)))
        }
      } message: {
        if let errorMessage = store.errorMessage {
          Text(errorMessage)
        }
      }
    }
    
    // MARK: - Initial Loading View
    private var initialLoadingView: some View {
      VStack(spacing: GitHubSpacing.xl) {
        Spacer()
        
        VStack(spacing: GitHubSpacing.lg) {
          // GitHub 로고 애니메이션
          Image(systemName: "octagon.fill")
            .font(.system(size: 60))
            .foregroundColor(.githubBlue)
            .scaleEffect(1.0)
            .animation(
              Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
              value: store.isInitialLoading
            )
          
          VStack(spacing: GitHubSpacing.sm) {
            Text("프로필 로딩 중")
              .font(.githubTitle2)
              .fontWeight(.semibold)
              .foregroundColor(.githubPrimaryText)
            
            Text("잠시만 기다려주세요...")
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
          }
          
          // 진행률 인디케이터
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .githubBlue))
            .scaleEffect(1.2)
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.githubBackground)
    }
    
    // MARK: - Authenticated Profile View
    private var authenticatedProfileView: some View {
      ScrollView {
        VStack(spacing: GitHubSpacing.lg) {
          // 프로필 헤더
          ProfileHeader(
            userProfile: store.userProfile,
            isAuthenticated: store.isAuthenticated,
            onSignInTapped: { store.send(.signInTapped) },
            onEditProfileTapped: { store.send(.editProfileTapped) },
            onShareProfileTapped: { store.send(.shareProfileTapped) }
          )
          
          // 통계 섹션
          ProfileStats(userProfile: store.userProfile)
          
          // 메뉴 섹션들
          ProfileMenuSection(store: store)
          
          // 인기 리포지토리 섹션 (미리보기)
          if !store.topRepositories.isEmpty {
            PopularRepositoriesSection(store: store)
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button {
            store.send(.settingsTapped)
          } label: {
            Image(systemName: "gear")
              .font(.system(size: GitHubIconSize.medium))
              .foregroundColor(.githubBlue)
          }
          
          Button {
            store.send(.shareProfileTapped)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: GitHubIconSize.medium))
              .foregroundColor(.githubBlue)
          }
        }
      }
    }
    
    // MARK: - Login View
    private var loginView: some View {
      VStack(spacing: GitHubSpacing.xl) {
        Spacer()
        
        // GitHub 로고 및 제목
        VStack(spacing: GitHubSpacing.lg) {
          Image(systemName: "octagon.fill")
            .font(.system(size: 80))
            .foregroundColor(.githubBlue)
          
          VStack(spacing: GitHubSpacing.sm) {
            Text("GitHub에 로그인")
              .font(.githubTitle1)
              .fontWeight(.bold)
              .foregroundColor(.githubPrimaryText)
            
            Text("리포지토리와 프로필을 확인하세요")
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
              .multilineTextAlignment(.center)
          }
        }
        
        Spacer()
        
        // 로그인 버튼
        VStack(spacing: GitHubSpacing.md) {
          Button {
            store.send(.signInTapped)
          } label: {
            HStack(spacing: GitHubSpacing.sm) {
              if store.isLoading {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .scaleEffect(0.8)
              } else {
                Image(systemName: "octagon.fill")
                  .font(.system(size: GitHubIconSize.medium))
              }
              
              Text(store.isLoading ? "로그인 중..." : "GitHub로 로그인")
                .font(.githubSubheadline)
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
              RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
                .fill(Color.githubBlue)
            )
          }
          .disabled(store.isLoading)
          
          Text("GitHub 계정으로 안전하게 로그인하세요")
            .font(.githubCaption)
            .foregroundColor(.githubTertiaryText)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        
        Spacer()
      }
    }
  }
  
  // MARK: - Profile Header
  private struct ProfileHeader: View {
    let userProfile: ProfileModel.UserProfile
    let isAuthenticated: Bool
    let onSignInTapped: () -> Void
    let onEditProfileTapped: () -> Void
    let onShareProfileTapped: () -> Void
    
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        // 아바타 및 기본 정보
        HStack(spacing: GitHubSpacing.md) {
          // 아바타
          AsyncImage(url: URL(string: userProfile.avatar ?? "")) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Circle()
              .fill(Color.githubGreen)
              .overlay(
                Text(String(userProfile.displayName.prefix(1)))
                  .font(.system(size: 32, weight: .bold))
                  .foregroundColor(.white)
              )
          }
          .frame(width: 80, height: 80)
          .clipShape(Circle())
          
          VStack(alignment: .leading, spacing: GitHubSpacing.xs) {
            Text(userProfile.displayName)
              .font(.githubTitle2)
              .fontWeight(.bold)
              .foregroundColor(.githubPrimaryText)
            
            Text(userProfile.username)
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
            
            if let company = userProfile.company {
              HStack(spacing: GitHubSpacing.xs) {
                Image(systemName: "building.2")
                  .font(.system(size: GitHubIconSize.small))
                  .foregroundColor(.githubSecondaryText)
                
                Text(company)
                  .font(.githubSubheadline)
                  .foregroundColor(.githubSecondaryText)
              }
            }
          }
          
          Spacer()
        }
        
        // 상태 메시지
        if let bio = userProfile.bio {
          HStack(spacing: GitHubSpacing.sm) {
            Image(systemName: "face.smiling")
              .font(.system(size: GitHubIconSize.medium))
              .foregroundColor(.githubSecondaryText)
            
            Text(bio)
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
              onEditProfileTapped()
            } label: {
              Image(systemName: "pencil")
                .font(.system(size: GitHubIconSize.small))
                .foregroundColor(.githubSecondaryText)
            }
          }
          .padding(.horizontal, GitHubSpacing.md)
          .padding(.vertical, GitHubSpacing.sm)
          .background(
            RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
              .fill(Color.githubSecondaryBackground)
          )
        }
        
        // 팔로워/팔로잉 정보
        HStack(spacing: GitHubSpacing.md) {
          HStack(spacing: GitHubSpacing.xs) {
            Image(systemName: "person.2.fill")
              .font(.system(size: GitHubIconSize.small))
              .foregroundColor(.githubSecondaryText)
            
            Text("\(userProfile.followerCount) 팔로워")
              .font(.githubSubheadline)
              .foregroundColor(.githubSecondaryText)
          }
          
          Text("·")
            .foregroundColor(.githubTertiaryText)
          
          Text("\(userProfile.followingCount) 팔로우하는 중")
            .font(.githubSubheadline)
            .foregroundColor(.githubSecondaryText)
          
          Spacer()
        }
      }
    }
  }
  
  // MARK: - Profile Stats
  private struct ProfileStats: View {
    let userProfile: ProfileModel.UserProfile
    
    var body: some View {
      GitHubCard {
        VStack(spacing: GitHubSpacing.md) {
          HStack {
            Text("통계")
              .font(.githubHeadline)
              .fontWeight(.semibold)
              .foregroundColor(.githubPrimaryText)
            
            Spacer()
          }
          
          HStack(spacing: GitHubSpacing.md) {
            StatItem(
              icon: "folder.fill",
              iconColor: .githubSecondaryText,
              title: "리포지토리",
              count: userProfile.publicRepos
            )
            
            StatItem(
              icon: "star.fill",
              iconColor: .githubWarning,
              title: "별표 표시",
              count: userProfile.starredRepos
            )
            
            StatItem(
              icon: "building.2.fill",
              iconColor: .githubOrange,
              title: "조직",
              count: userProfile.organizations
            )
          }
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.md)
      }
    }
  }
  
  // MARK: - Stat Item
  private struct StatItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let count: Int
    
    var body: some View {
      VStack(spacing: GitHubSpacing.xs) {
        HStack(spacing: GitHubSpacing.xs) {
          Image(systemName: icon)
            .font(.system(size: GitHubIconSize.medium))
            .foregroundColor(iconColor)
          
          Text("\(count)")
            .font(.githubTitle3)
            .fontWeight(.bold)
            .foregroundColor(.githubPrimaryText)
        }
        
        Text(title)
          .font(.githubCaption)
          .foregroundColor(.githubSecondaryText)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
    }
  }
  
  // MARK: - Menu Section
  private struct ProfileMenuSection: View {
    @Bindable var store: StoreOf<ProfileReducer>
    
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        ForEach(store.menuItems) { menuItem in
          ProfileMenuItem(
            item: menuItem,
            onTap: {
              store.send(.menuItemTapped(menuItem.type))
            }
          )
        }
      }
    }
  }
  
  // MARK: - Profile Menu Item
  private struct ProfileMenuItem: View {
    let item: ProfileModel.ProfileMenuItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        HStack(spacing: GitHubSpacing.md) {
          // 아이콘
          RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
            .fill(item.iconColor.opacity(0.1))
            .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)
            .overlay(
              Image(systemName: item.icon)
                .font(.system(size: GitHubIconSize.medium))
                .foregroundColor(item.iconColor)
            )
          
          // 내용
          VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
            HStack {
              Text(item.title)
                .font(.githubSubheadline)
                .fontWeight(.medium)
                .foregroundColor(.githubPrimaryText)
              
              if let badgeCount = item.badgeCount {
                Text("\(badgeCount)")
                  .font(.githubCaption)
                  .foregroundColor(.githubSecondaryText)
                  .padding(.horizontal, GitHubSpacing.xs)
                  .padding(.vertical, 2)
                  .background(
                    RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
                      .fill(Color.githubTertiaryBackground)
                  )
              }
              
              Spacer()
            }
            
            if let subtitle = item.subtitle {
              Text(subtitle)
                .font(.githubCaption)
                .foregroundColor(.githubTertiaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          
          // 화살표
          if item.hasChevron {
            Image(systemName: "chevron.right")
              .font(.system(size: GitHubIconSize.small))
              .foregroundColor(.githubTertiaryText)
          }
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.md)
        .background(
          RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
            .fill(Color.githubCardBackground)
        )
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
  
  // MARK: - Popular Repositories Section
  private struct PopularRepositoriesSection: View {
    @Bindable var store: StoreOf<ProfileReducer>
    
    var body: some View {
      VStack(spacing: GitHubSpacing.md) {
        HStack {
          Text("인기")
            .font(.githubHeadline)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
          
          Spacer()
          
          Button {
            store.send(.viewAllRepositoriesTapped)
          } label: {
            Text("모두 보기")
              .font(.githubSubheadline)
              .foregroundColor(.githubBlue)
          }
        }
        
        VStack(spacing: GitHubSpacing.sm) {
          ForEach(store.topRepositories) { repository in
            RepositoryCard(
              repository: repository,
              onTap: {
                store.send(.repositoryTapped(repository))
              }
            )
          }
        }
      }
    }
  }
  
  // MARK: - Repository Card
  private struct RepositoryCard: View {
    let repository: ProfileModel.RepositoryItem
    let onTap: () -> Void
    
    var body: some View {
      Button(action: onTap) {
        GitHubCard {
          VStack(alignment: .leading, spacing: GitHubSpacing.sm) {
            // 헤더
            HStack {
              HStack(spacing: GitHubSpacing.xs) {
                Image(systemName: "person.crop.circle.fill")
                  .font(.system(size: GitHubIconSize.medium))
                  .foregroundColor(.githubSecondaryText)
                
                Text(repository.fullName)
                  .font(.githubSubheadline)
                  .fontWeight(.medium)
                  .foregroundColor(.githubPrimaryText)
              }
              
              Spacer()
              
              if repository.isPrivate {
                Text("private")
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
            
            // 제목
            Text(repository.name)
              .font(.githubTitle3)
              .fontWeight(.bold)
              .foregroundColor(.githubPrimaryText)
              .frame(maxWidth: .infinity, alignment: .leading)
            
            // 설명
            if let description = repository.description {
              Text(description)
                .font(.githubSubheadline)
                .foregroundColor(.githubSecondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
            }
            
            // 하단 정보
            HStack {
              if let language = repository.language, let languageColor = repository.languageColor {
                HStack(spacing: GitHubSpacing.xs) {
                  Circle()
                    .fill(languageColor)
                    .frame(width: 8, height: 8)
                  
                  Text(language)
                    .font(.githubCaption)
                    .foregroundColor(.githubSecondaryText)
                }
              }
              
              HStack(spacing: GitHubSpacing.xs) {
                Image(systemName: "star")
                  .font(.system(size: GitHubIconSize.small))
                  .foregroundColor(.githubSecondaryText)
                
                Text("\(repository.starCount)")
                  .font(.githubCaption)
                  .foregroundColor(.githubSecondaryText)
              }
              
              Spacer()
              
              Text(repository.updatedAt)
                .font(.githubCaption)
                .foregroundColor(.githubTertiaryText)
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

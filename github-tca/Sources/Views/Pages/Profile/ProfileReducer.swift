import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileReducer {
  @Dependency(\.navigation) var navigation
  @Dependency(\.gitHubClient) var gitHubClient
  @Dependency(\.gitHubAuthClient) var gitHubAuthClient
  
  @ObservableState
  struct State: Equatable {
    var userProfile: ProfileModel.UserProfile = .default
    var menuItems: [ProfileModel.ProfileMenuItem] = .default
    var repositories: [ProfileModel.RepositoryItem] = .default
    var isLoading = false
    var showingSignOutAlert = false
    var showingEditProfile = false
    var isAuthenticated = false
    var errorMessage: String?
    
    // 필터링된 리포지토리 (상위 3개만 표시)
    var topRepositories: [ProfileModel.RepositoryItem] {
      Array(repositories.prefix(3))
    }
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case loadProfile
    case refreshProfile
    case checkAuthenticationStatus
    case signInTapped
    case signInResponse(Result<GitHubAuthResult, Error>)
    case loadUserProfile
    case userProfileResponse(Result<GitHubUser, Error>)
    case loadUserRepositories
    case userRepositoriesResponse(Result<[GitHubRepository], Error>)
    case menuItemTapped(ProfileModel.ProfileMenuItem.MenuType)
    case editProfileTapped
    case shareProfileTapped
    case settingsTapped
    case repositoryTapped(ProfileModel.RepositoryItem)
    case viewAllRepositoriesTapped
    case signOutTapped
    case signOutConfirmed
    case signOutCancelled
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .loadProfile:
        // 먼저 간단하게 키체인 토큰 확인
        return .send(.checkAuthenticationStatus)
        
      case .checkAuthenticationStatus:
        state.isLoading = true
        state.errorMessage = nil
        return .run { [gitHubAuthClient] send in
          do {
            // Keychain에 토큰이 있는지 간단히 확인
            let hasToken = try await gitHubAuthClient.getAccessToken() != nil
            if hasToken {
              await send(.binding(.set(\.isAuthenticated, true)))
              await send(.loadUserProfile)
            } else {
              await send(.binding(.set(\.isAuthenticated, false)))
              await send(.binding(.set(\.isLoading, false)))
            }
          } catch {
            // 토큰 확인 실패 시 로그아웃 상태로 처리
            await send(.binding(.set(\.isAuthenticated, false)))
            await send(.binding(.set(\.isLoading, false)))
            await send(.binding(.set(\.errorMessage, "인증 상태 확인 실패")))
          }
        }
        
      case .refreshProfile:
        // 새로고침 시에도 키체인 토큰 확인
        return .send(.checkAuthenticationStatus)
        
      case .signInTapped:
        state.isLoading = true
        state.errorMessage = nil
        return .run { [gitHubAuthClient] send in
          await send(.signInResponse(
            Result {
              try await gitHubAuthClient.signIn()
            }
          ))
        }
        
      case let .signInResponse(.success(authResult)):
        state.isLoading = false
        state.isAuthenticated = true
        state.userProfile = authResult.user.toUserProfile()
        return .run { send in
          await send(.loadUserRepositories)
        }
        
      case let .signInResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case .loadUserProfile:
        return .run { [gitHubClient] send in
          await send(.userProfileResponse(
            Result {
              try await gitHubClient.getCurrentUser()
            }
          ))
        }
        
      case let .userProfileResponse(.success(user)):
        state.userProfile = user.toUserProfile()
        state.isAuthenticated = true
        state.isLoading = false
        return .run { send in
          await send(.loadUserRepositories)
        }
        
      case let .userProfileResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case .loadUserRepositories:
        return .run { [gitHubClient, username = state.userProfile.username] send in
          await send(.userRepositoriesResponse(
            Result {
              try await gitHubClient.getUserRepositories(
                username: username,
                page: 1,
                perPage: 10
              )
            }
          ))
        }
        
      case let .userRepositoriesResponse(.success(repos)):
        state.repositories = repos.map { $0.toProfileRepositoryItem() }
        return .none
        
      case let .userRepositoriesResponse(.failure(error)):
        state.errorMessage = error.localizedDescription
        return .none
        
      case let .menuItemTapped(menuType):
        switch menuType {
        case .repositories:
          return .run { send in
            await send(.viewAllRepositoriesTapped)
          }
          
        case .starred:
          print("별표 표시한 리포지토리로 이동")
          return .none
          
        case .organizations:
          print("조직 목록으로 이동")
          return .none
          
        case .settings:
          return .run { send in
            await send(.settingsTapped)
          }
          
        case .notifications:
          print("알림 설정으로 이동")
          return .none
          
        case .security:
          print("보안 설정으로 이동")
          return .none
          
        case .billing:
          print("결제 설정으로 이동")
          return .none
          
        case .appearance:
          print("모양 설정으로 이동")
          return .none
          
        case .help:
          print("도움말로 이동")
          return .none
          
        case .signOut:
          return .run { send in
            await send(.signOutTapped)
          }
        }
        
      case .editProfileTapped:
        state.showingEditProfile = true
        return .none
        
      case .shareProfileTapped:
        print("프로필 공유")
        return .none
        
      case .settingsTapped:
        return .run { [navigation] _ in
          await navigation.goToSettings()
        }
        
      case let .repositoryTapped(repository):
        return .run { _ in
          await navigation.goToRepositoryDetail(repository)
        }
        
      case .viewAllRepositoriesTapped:
        return .run { _ in
          await navigation.goToRepositoryList()
        }
        
      case .signOutTapped:
        state.showingSignOutAlert = true
        return .none
        
      case .signOutConfirmed:
        state.showingSignOutAlert = false
        state.isLoading = true
        return .run { send in
          // Navigation을 통해 AppReducer로 로그아웃 요청
          await navigation.signOut()
          await send(.binding(.set(\.isAuthenticated, false)))
          await send(.binding(.set(\.isLoading, false)))
          await send(.binding(.set(\.userProfile, .default)))
          await send(.binding(.set(\.repositories, .default)))
        }
        
      case .signOutCancelled:
        state.showingSignOutAlert = false
        return .none
      }
    }
  }
}

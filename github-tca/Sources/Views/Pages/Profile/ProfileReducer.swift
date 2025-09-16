import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileReducer {
  @Dependency(\.navigation) var navigation
  
  @ObservableState
  struct State: Equatable {
    var userProfile: ProfileModel.UserProfile = .default
    var menuItems: [ProfileModel.ProfileMenuItem] = .default
    var repositories: [ProfileModel.RepositoryItem] = .default
    var isLoading = false
    var showingSignOutAlert = false
    var showingEditProfile = false
    
    // 필터링된 리포지토리 (상위 3개만 표시)
    var topRepositories: [ProfileModel.RepositoryItem] {
      Array(repositories.prefix(3))
    }
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case loadProfile
    case refreshProfile
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
        state.isLoading = true
        return .run { send in
          // 프로필 데이터 로드 시뮬레이션
          try await Task.sleep(nanoseconds: 1_000_000_000)
          await send(.binding(.set(\.isLoading, false)))
        }
        
      case .refreshProfile:
        state.isLoading = true
        return .run { send in
          // 프로필 새로고침 시뮬레이션
          try await Task.sleep(nanoseconds: 500_000_000)
          await send(.binding(.set(\.isLoading, false)))
        }
        
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
        print("설정 화면으로 이동")
        return .none
        
      case let .repositoryTapped(repository):
        print("리포지토리 탭됨: \(repository.name)")
        return .none
        
      case .viewAllRepositoriesTapped:
        print("모든 리포지토리 보기")
        return .none
        
      case .signOutTapped:
        state.showingSignOutAlert = true
        return .none
        
      case .signOutConfirmed:
        state.showingSignOutAlert = false
        // 실제 로그아웃 로직
        return .run { _ in
          print("로그아웃 처리")
          // 로그아웃 후 로그인 화면으로 이동
        }
        
      case .signOutCancelled:
        state.showingSignOutAlert = false
        return .none
      }
    }
  }
}

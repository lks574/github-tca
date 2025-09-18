import Foundation
import ComposableArchitecture
import AuthenticationServices

// MARK: - GitHub Auth Client

/// GitHub OAuth 인증 클라이언트 (TCA Dependency)
@DependencyClient
public struct GitHubAuthClient: Sendable {
  
  // MARK: - Authentication Operations
  
  /// OAuth 로그인 시작
  public var signIn: @Sendable () async throws -> GitHubAuthResult
  
  /// 로그아웃
  public var signOut: @Sendable () async throws -> Void
  
  /// 현재 인증 상태 확인
  public var isAuthenticated: @Sendable () async throws -> Bool
  
  /// 액세스 토큰 가져오기
  public var getAccessToken: @Sendable () async throws -> String?
  
  /// 사용자 정보 새로고침
  public var refreshUserInfo: @Sendable () async throws -> GitHubUser
  
  /// 토큰 유효성 검사
  public var validateToken: @Sendable () async throws -> Bool
}

// MARK: - Auth Result

public struct GitHubAuthResult: Equatable, Sendable {
  public let accessToken: String
  public let user: GitHubUser
  
  public init(accessToken: String, user: GitHubUser) {
    self.accessToken = accessToken
    self.user = user
  }
}

// MARK: - Dependency Key

extension GitHubAuthClient: DependencyKey {
  
  /// Live 구현체 (실제 OAuth 인증)
  public static let liveValue: GitHubAuthClient = {
    let authService = GitHubAuthService()
    
    return GitHubAuthClient(
      signIn: {
        try await authService.signIn()
      },
      signOut: {
        try await authService.signOut()
      },
      isAuthenticated: {
        try await authService.isAuthenticated()
      },
      getAccessToken: {
        try await authService.getAccessToken()
      },
      refreshUserInfo: {
        try await authService.refreshUserInfo()
      },
      validateToken: {
        try await authService.validateToken()
      }
    )
  }()
  
  /// Test 구현체 (Mock 데이터 사용)
  public static let testValue: GitHubAuthClient = {
    let mockService = MockGitHubAuthService()
    
    return GitHubAuthClient(
      signIn: {
        try await mockService.signIn()
      },
      signOut: {
        try await mockService.signOut()
      },
      isAuthenticated: {
        try await mockService.isAuthenticated()
      },
      getAccessToken: {
        try await mockService.getAccessToken()
      },
      refreshUserInfo: {
        try await mockService.refreshUserInfo()
      },
      validateToken: {
        try await mockService.validateToken()
      }
    )
  }()
  
  /// Preview 구현체 (SwiftUI Preview용)
  public static let previewValue: GitHubAuthClient = testValue
}

// MARK: - Dependency Values Extension

extension DependencyValues {
  
  /// GitHub 인증 클라이언트 의존성
  public var gitHubAuthClient: GitHubAuthClient {
    get { self[GitHubAuthClient.self] }
    set { self[GitHubAuthClient.self] = newValue }
  }
}

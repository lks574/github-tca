import Foundation

// MARK: - GitHub Auth Service

final class GitHubAuthService: NSObject, Sendable {

  // GitHub OAuth 설정
  private let clientId = "YOUR_GITHUB_CLIENT_ID" // 실제 앱에서는 환경변수나 설정 파일에서 가져와야 함
  private let clientSecret = "YOUR_GITHUB_CLIENT_SECRET"
  private let redirectUri = "github-tca://oauth/callback"
  private let scope = "user:email,repo,read:org"

  private let keychain = KeychainService()

  func signIn() async throws -> GitHubAuthResult {
    return try await withCheckedThrowingContinuation { continuation in
      let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&scope=\(scope)")!

      // 실제 구현에서는 ASWebAuthenticationSession을 사용해야 함
      // 여기서는 시뮬레이션으로 처리
      Task {
        do {
          // Mock 데이터로 시뮬레이션
          let mockUser = GitHubUser(
            id: 12345,
            login: "testuser",
            avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
            url: "https://api.github.com/users/testuser",
            htmlUrl: "https://github.com/testuser",
            type: "User",
            siteAdmin: false,
            name: "Test User",
            company: "GitHub Inc.",
            blog: "https://github.com/testuser",
            location: "Seoul, South Korea",
            email: "testuser@example.com",
            bio: "iOS Developer passionate about clean architecture and TCA",
            publicRepos: 25,
            publicGists: 10,
            followers: 42,
            following: 15,
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2024-01-15T10:30:00Z"
          )

          let mockToken = "mock_access_token_\(UUID().uuidString)"

          // 토큰을 키체인에 저장
          try await keychain.store(token: mockToken)

          let result = GitHubAuthResult(accessToken: mockToken, user: mockUser)
          continuation.resume(returning: result)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func signOut() async throws {
    try await keychain.deleteToken()
  }

  func isAuthenticated() async throws -> Bool {
    let token = try await keychain.getToken()
    return token != nil
  }

  func getAccessToken() async throws -> String? {
    return try await keychain.getToken()
  }

  func refreshUserInfo() async throws -> GitHubUser {
    guard let token = try await keychain.getToken() else {
      throw GitHubError.authenticationRequired
    }

    // 실제로는 GitHub API를 호출해야 함
    // 여기서는 Mock 데이터 반환
    return GitHubUser(
      id: 12345,
      login: "testuser",
      avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
      url: "https://api.github.com/users/testuser",
      htmlUrl: "https://github.com/testuser",
      type: "User",
      siteAdmin: false,
      name: "Test User",
      company: "GitHub Inc.",
      blog: "https://github.com/testuser",
      location: "Seoul, South Korea",
      email: "testuser@example.com",
      bio: "iOS Developer passionate about clean architecture and TCA",
      publicRepos: 25,
      publicGists: 10,
      followers: 42,
      following: 15,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2024-01-15T10:30:00Z"
    )
  }

  func validateToken() async throws -> Bool {
    guard let token = try await keychain.getToken() else {
      return false
    }

    // 실제로는 GitHub API /user 엔드포인트를 호출해서 토큰 유효성 검사
    // 여기서는 시뮬레이션으로 처리
    if token.isEmpty {
      return false
    }

    // Mock에서는 항상 유효한 것으로 처리
    return true
  }

  func authStateChanged() -> AsyncStream<AuthState> {
    AsyncStream { continuation in
      // 실제로는 토큰 상태 변화를 감지하고 알림
      // 여기서는 시뮬레이션으로 현재 상태만 반환
      Task {
        do {
          let isAuth = try await isAuthenticated()
          if isAuth {
            let user = try await refreshUserInfo()
            continuation.yield(.authenticated(user))
          } else {
            continuation.yield(.unauthenticated)
          }
        } catch {
          continuation.yield(.error(error as? GitHubError ?? .unknown(error.localizedDescription)))
        }
      }
    }
  }
}

// MARK: - Mock GitHub Auth Service

final class MockGitHubAuthService: Sendable {

  func signIn() async throws -> GitHubAuthResult {
    // Mock 데이터 반환
    let mockUser = GitHubUser(
      id: 12345,
      login: "testuser",
      avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
      url: "https://api.github.com/users/testuser",
      htmlUrl: "https://github.com/testuser",
      type: "User",
      siteAdmin: false,
      name: "Test User",
      company: "GitHub Inc.",
      blog: "https://github.com/testuser",
      location: "Seoul, South Korea",
      email: "testuser@example.com",
      bio: "iOS Developer passionate about clean architecture and TCA",
      publicRepos: 25,
      publicGists: 10,
      followers: 42,
      following: 15,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2024-01-15T10:30:00Z"
    )

    let mockToken = "mock_access_token_\(UUID().uuidString)"
    return GitHubAuthResult(accessToken: mockToken, user: mockUser)
  }

  func signOut() async throws {
    // Mock 로그아웃
  }

  func isAuthenticated() async throws -> Bool {
    return true // Mock에서는 항상 인증됨
  }

  func getAccessToken() async throws -> String? {
    return "mock_access_token"
  }

  func refreshUserInfo() async throws -> GitHubUser {
    return GitHubUser(
      id: 12345,
      login: "testuser",
      avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
      url: "https://api.github.com/users/testuser",
      htmlUrl: "https://github.com/testuser",
      type: "User",
      siteAdmin: false,
      name: "Test User",
      company: "GitHub Inc.",
      blog: "https://github.com/testuser",
      location: "Seoul, South Korea",
      email: "testuser@example.com",
      bio: "iOS Developer passionate about clean architecture and TCA",
      publicRepos: 25,
      publicGists: 10,
      followers: 42,
      following: 15,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2024-01-15T10:30:00Z"
    )
  }

  func validateToken() async throws -> Bool {
    return true // Mock에서는 항상 유효
  }

  func authStateChanged() -> AsyncStream<AuthState> {
    AsyncStream { continuation in
      // Mock에서는 인증된 상태로 시작
      let mockUser = GitHubUser(
        id: 12345,
        login: "testuser",
        avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
        url: "https://api.github.com/users/testuser",
        htmlUrl: "https://github.com/testuser",
        type: "User",
        siteAdmin: false,
        name: "Test User",
        company: "GitHub Inc.",
        blog: "https://github.com/testuser",
        location: "Seoul, South Korea",
        email: "testuser@example.com",
        bio: "iOS Developer passionate about clean architecture and TCA",
        publicRepos: 25,
        publicGists: 10,
        followers: 42,
        following: 15,
        createdAt: "2020-01-01T00:00:00Z",
        updatedAt: "2024-01-15T10:30:00Z"
      )
      continuation.yield(.authenticated(mockUser))
    }
  }
}

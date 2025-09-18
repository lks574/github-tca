import Foundation

// MARK: - Mock Service for Testing

/// 테스트용 Mock GitHub 인증 서비스
public struct MockGitHubAuthService: GitHubAuthServiceProtocol {

  public init() {}

  public func signIn() async throws -> GitHubAuthResult {
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

  public func signOut() async throws {
    // Mock 로그아웃 (실제 동작 없음)
  }

  public func isAuthenticated() async throws -> Bool {
    return true // Mock에서는 항상 인증됨
  }

  public func getAccessToken() async throws -> String? {
    return "mock_access_token"
  }

  public func refreshUserInfo() async throws -> GitHubUser {
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

  public func validateToken() async throws -> Bool {
    return true // Mock에서는 항상 유효
  }

  public func restoreAuthenticationIfPossible() async throws -> GitHubAuthResult? {
    // Mock에서는 항상 성공적으로 복원
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

    return GitHubAuthResult(accessToken: "mock_restored_token", user: mockUser)
  }
}


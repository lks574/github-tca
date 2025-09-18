import Foundation

// MARK: - Mock Service for Testing

/// 테스트용 Mock GitHub 서비스
public struct MockGitHubService: GitHubServiceProtocol {

  public init() {}

  public func searchRepositories(parameters: GitHubSearchParameters) async throws -> GitHubSearchResponse {
    // Mock 데이터 반환
    let mockUser = GitHubUser(
      id: 1,
      login: "pointfreeco",
      avatarUrl: "https://avatars.githubusercontent.com/u/2400888?v=4",
      url: "https://api.github.com/users/pointfreeco",
      htmlUrl: "https://github.com/pointfreeco",
      type: "Organization",
      siteAdmin: false
    )

    let mockLicense = GitHubLicense(
      key: "mit",
      name: "MIT License",
      spdxId: "MIT",
      url: "https://api.github.com/licenses/mit",
      nodeId: "MDc6TGljZW5zZW1pdA=="
    )

    let mockRepository = GitHubRepository(
      id: 130159652,
      name: "swift-composable-architecture",
      fullName: "pointfreeco/swift-composable-architecture",
      owner: mockUser,
      description: "A library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind.",
      language: "Swift",
      stargazersCount: 12000,
      forksCount: 1500,
      watchersCount: 12000,
      openIssuesCount: 10,
      size: 2500,
      defaultBranch: "main",
      updatedAt: "2024-01-15T10:30:00Z",
      createdAt: "2018-04-18T19:15:23Z",
      pushedAt: "2024-01-15T10:30:00Z",
      htmlUrl: "https://github.com/pointfreeco/swift-composable-architecture",
      cloneUrl: "https://github.com/pointfreeco/swift-composable-architecture.git",
      sshUrl: "git@github.com:pointfreeco/swift-composable-architecture.git",
      isPrivate: false,
      isFork: false,
      isArchived: false,
      hasIssues: true,
      hasProjects: true,
      hasWiki: true,
      hasPages: false,
      hasDownloads: true,
      license: mockLicense,
      topics: ["swift", "ios", "architecture", "tca", "composable"]
    )

    return GitHubSearchResponse(
      totalCount: 1,
      incompleteResults: false,
      items: [mockRepository]
    )
  }

  public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
    let searchResult = try await searchRepositories(parameters: GitHubSearchParameters(query: "\(owner)/\(repo)"))
    guard let repository = searchResult.items.first else {
      throw GitHubError.notFound
    }
    return repository
  }

  public func getUser(username: String) async throws -> GitHubUser {
    return GitHubUser(
      id: 1,
      login: username,
      avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
      url: "https://api.github.com/users/\(username)",
      htmlUrl: "https://github.com/\(username)",
      type: "User",
      siteAdmin: false,
      name: "Test User",
      company: "GitHub Inc.",
      blog: "https://github.com/\(username)",
      location: "San Francisco, CA",
      email: "\(username)@example.com",
      bio: "iOS Developer passionate about clean architecture and TCA",
      publicRepos: 25,
      publicGists: 10,
      followers: 42,
      following: 15,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2024-01-15T10:30:00Z"
    )
  }

  public func getCurrentUser() async throws -> GitHubUser {
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

  public func getUserRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository] {
    // Mock 리포지토리 데이터
    let mockUser = GitHubUser(
      id: 12345,
      login: username,
      avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
      url: "https://api.github.com/users/\(username)",
      htmlUrl: "https://github.com/\(username)",
      type: "User",
      siteAdmin: false,
      name: "Test User",
      company: "GitHub Inc.",
      blog: "https://github.com/\(username)",
      location: "Seoul, South Korea",
      email: "\(username)@example.com",
      bio: "iOS Developer passionate about clean architecture and TCA",
      publicRepos: 25,
      publicGists: 10,
      followers: 42,
      following: 15,
      createdAt: "2020-01-01T00:00:00Z",
      updatedAt: "2024-01-15T10:30:00Z"
    )

    let mockRepositories = [
      GitHubRepository(
        id: 1,
        name: "awesome-project",
        fullName: "\(username)/awesome-project",
        owner: mockUser,
        description: "An awesome project built with Swift and TCA",
        language: "Swift",
        stargazersCount: 42,
        forksCount: 8,
        watchersCount: 42,
        openIssuesCount: 3,
        size: 1500,
        defaultBranch: "main",
        updatedAt: "2024-01-15T10:30:00Z",
        createdAt: "2024-01-01T00:00:00Z",
        pushedAt: "2024-01-15T10:30:00Z",
        htmlUrl: "https://github.com/\(username)/awesome-project",
        cloneUrl: "https://github.com/\(username)/awesome-project.git",
        sshUrl: "git@github.com:\(username)/awesome-project.git",
        isPrivate: false,
        isFork: false,
        isArchived: false,
        hasIssues: true,
        hasProjects: true,
        hasWiki: true,
        hasPages: false,
        hasDownloads: true,
        license: nil,
        topics: ["swift", "ios", "tca"]
      ),
      GitHubRepository(
        id: 2,
        name: "learning-ios",
        fullName: "\(username)/learning-ios",
        owner: mockUser,
        description: "iOS development learning repository",
        language: "Swift",
        stargazersCount: 15,
        forksCount: 2,
        watchersCount: 15,
        openIssuesCount: 1,
        size: 800,
        defaultBranch: "main",
        updatedAt: "2024-01-14T15:20:00Z",
        createdAt: "2024-01-05T00:00:00Z",
        pushedAt: "2024-01-14T15:20:00Z",
        htmlUrl: "https://github.com/\(username)/learning-ios",
        cloneUrl: "https://github.com/\(username)/learning-ios.git",
        sshUrl: "git@github.com:\(username)/learning-ios.git",
        isPrivate: true,
        isFork: false,
        isArchived: false,
        hasIssues: false,
        hasProjects: false,
        hasWiki: false,
        hasPages: false,
        hasDownloads: false,
        license: nil,
        topics: ["swift", "ios", "learning"]
      )
    ]

    return mockRepositories
  }

  public func getUserStarredRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository] {
    // Mock 별표 표시한 리포지토리 데이터
    let searchResult = try await searchRepositories(parameters: GitHubSearchParameters(query: "swift", page: page, perPage: perPage))
    return searchResult.items
  }
}

// MARK: - GitHub API Core Module
//
// 이 파일은 GitHub API 관련 모든 공용 타입과 클라이언트를 익스포트합니다.
// 다른 모듈에서는 이 파일만 import하면 모든 GitHub 기능을 사용할 수 있습니다.

// GitHub Models
public typealias GitHub = GitHubNamespace

public enum GitHubNamespace {
  // Models
  public typealias SearchResponse = GitHubSearchResponse
  public typealias Repository = GitHubRepository
  public typealias User = GitHubUser
  public typealias License = GitHubLicense
  public typealias SearchParameters = GitHubSearchParameters
  public typealias SearchSort = GitHubSearchSort
  public typealias SearchOrder = GitHubSearchOrder
  
  // Errors
  public typealias Error = GitHubError
  
  // Services
  public typealias Service = GitHubService
  public typealias ServiceProtocol = GitHubServiceProtocol
  public typealias MockService = MockGitHubService
  
  // Client
  public typealias Client = GitHubClient
}

// MARK: - Convenience Extensions

extension GitHubSearchParameters {
  
  /// Swift 레포지토리 검색을 위한 편의 이니셜라이저
  public static func swiftRepositories(
    page: Int = 1,
    perPage: Int = 30
  ) -> GitHubSearchParameters {
    GitHubSearchParameters(
      query: "language:swift",
      sort: .stars,
      order: .desc,
      page: page,
      perPage: perPage
    )
  }
  
  /// iOS 관련 레포지토리 검색을 위한 편의 이니셜라이저
  public static func iOSRepositories(
    page: Int = 1,
    perPage: Int = 30
  ) -> GitHubSearchParameters {
    GitHubSearchParameters(
      query: "ios OR iphone OR swift topic:ios",
      sort: .stars,
      order: .desc,
      page: page,
      perPage: perPage
    )
  }
  
  /// TCA 관련 레포지토리 검색을 위한 편의 이니셜라이저
  public static func tcaRepositories(
    page: Int = 1,
    perPage: Int = 30
  ) -> GitHubSearchParameters {
    GitHubSearchParameters(
      query: "composable-architecture OR tca topic:tca",
      sort: .stars,
      order: .desc,
      page: page,
      perPage: perPage
    )
  }
  
  /// 특정 언어의 인기 레포지토리 검색
  public static func popularRepositories(
    language: String,
    page: Int = 1,
    perPage: Int = 30
  ) -> GitHubSearchParameters {
    GitHubSearchParameters(
      query: "language:\(language)",
      sort: .stars,
      order: .desc,
      page: page,
      perPage: perPage
    )
  }
  
  /// 최근 업데이트된 레포지토리 검색
  public static func recentlyUpdated(
    query: String,
    page: Int = 1,
    perPage: Int = 30
  ) -> GitHubSearchParameters {
    GitHubSearchParameters(
      query: query,
      sort: .updated,
      order: .desc,
      page: page,
      perPage: perPage
    )
  }
}

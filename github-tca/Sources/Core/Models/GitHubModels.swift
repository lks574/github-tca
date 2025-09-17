import Foundation

// MARK: - GitHub API Response Models

/// GitHub 검색 API 응답 모델
public struct GitHubSearchResponse: Codable, Equatable, Sendable {
  public let totalCount: Int
  public let incompleteResults: Bool
  public let items: [GitHubRepository]
  
  public init(totalCount: Int, incompleteResults: Bool, items: [GitHubRepository]) {
    self.totalCount = totalCount
    self.incompleteResults = incompleteResults
    self.items = items
  }
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case incompleteResults = "incomplete_results"
    case items
  }
}

/// GitHub 레포지토리 모델
public struct GitHubRepository: Codable, Equatable, Identifiable, Sendable {
  public let id: Int
  public let name: String
  public let fullName: String
  public let owner: GitHubUser
  public let description: String?
  public let language: String?
  public let stargazersCount: Int
  public let forksCount: Int
  public let watchersCount: Int
  public let openIssuesCount: Int
  public let size: Int
  public let defaultBranch: String
  public let updatedAt: String
  public let createdAt: String
  public let pushedAt: String?
  public let htmlUrl: String
  public let cloneUrl: String
  public let sshUrl: String
  public let isPrivate: Bool
  public let isFork: Bool
  public let isArchived: Bool
  public let hasIssues: Bool
  public let hasProjects: Bool
  public let hasWiki: Bool
  public let hasPages: Bool
  public let hasDownloads: Bool
  public let license: GitHubLicense?
  public let topics: [String]?
  
  public init(
    id: Int,
    name: String,
    fullName: String,
    owner: GitHubUser,
    description: String? = nil,
    language: String? = nil,
    stargazersCount: Int,
    forksCount: Int,
    watchersCount: Int,
    openIssuesCount: Int,
    size: Int,
    defaultBranch: String,
    updatedAt: String,
    createdAt: String,
    pushedAt: String? = nil,
    htmlUrl: String,
    cloneUrl: String,
    sshUrl: String,
    isPrivate: Bool,
    isFork: Bool,
    isArchived: Bool,
    hasIssues: Bool,
    hasProjects: Bool,
    hasWiki: Bool,
    hasPages: Bool,
    hasDownloads: Bool,
    license: GitHubLicense? = nil,
    topics: [String]? = nil
  ) {
    self.id = id
    self.name = name
    self.fullName = fullName
    self.owner = owner
    self.description = description
    self.language = language
    self.stargazersCount = stargazersCount
    self.forksCount = forksCount
    self.watchersCount = watchersCount
    self.openIssuesCount = openIssuesCount
    self.size = size
    self.defaultBranch = defaultBranch
    self.updatedAt = updatedAt
    self.createdAt = createdAt
    self.pushedAt = pushedAt
    self.htmlUrl = htmlUrl
    self.cloneUrl = cloneUrl
    self.sshUrl = sshUrl
    self.isPrivate = isPrivate
    self.isFork = isFork
    self.isArchived = isArchived
    self.hasIssues = hasIssues
    self.hasProjects = hasProjects
    self.hasWiki = hasWiki
    self.hasPages = hasPages
    self.hasDownloads = hasDownloads
    self.license = license
    self.topics = topics
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, owner, description, language, size, topics
    case fullName = "full_name"
    case stargazersCount = "stargazers_count"
    case forksCount = "forks_count"
    case watchersCount = "watchers_count"
    case openIssuesCount = "open_issues_count"
    case defaultBranch = "default_branch"
    case updatedAt = "updated_at"
    case createdAt = "created_at"
    case pushedAt = "pushed_at"
    case htmlUrl = "html_url"
    case cloneUrl = "clone_url"
    case sshUrl = "ssh_url"
    case isPrivate = "private"
    case isFork = "fork"
    case isArchived = "archived"
    case hasIssues = "has_issues"
    case hasProjects = "has_projects"
    case hasWiki = "has_wiki"
    case hasPages = "has_pages"
    case hasDownloads = "has_downloads"
    case license
  }
}

/// GitHub 사용자 모델
public struct GitHubUser: Codable, Equatable, Identifiable, Sendable {
  public let id: Int
  public let login: String
  public let avatarUrl: String
  public let gravatarId: String?
  public let url: String
  public let htmlUrl: String
  public let type: String
  public let siteAdmin: Bool
  
  public init(
    id: Int,
    login: String,
    avatarUrl: String,
    gravatarId: String? = nil,
    url: String,
    htmlUrl: String,
    type: String,
    siteAdmin: Bool
  ) {
    self.id = id
    self.login = login
    self.avatarUrl = avatarUrl
    self.gravatarId = gravatarId
    self.url = url
    self.htmlUrl = htmlUrl
    self.type = type
    self.siteAdmin = siteAdmin
  }
  
  enum CodingKeys: String, CodingKey {
    case id, login, url, type
    case avatarUrl = "avatar_url"
    case gravatarId = "gravatar_id"
    case htmlUrl = "html_url"
    case siteAdmin = "site_admin"
  }
}

/// GitHub 라이센스 모델
public struct GitHubLicense: Codable, Equatable, Sendable {
  public let key: String
  public let name: String
  public let spdxId: String?
  public let url: String?
  public let nodeId: String
  
  public init(
    key: String,
    name: String,
    spdxId: String? = nil,
    url: String? = nil,
    nodeId: String
  ) {
    self.key = key
    self.name = name
    self.spdxId = spdxId
    self.url = url
    self.nodeId = nodeId
  }
  
  enum CodingKeys: String, CodingKey {
    case key, name, url
    case spdxId = "spdx_id"
    case nodeId = "node_id"
  }
}

// MARK: - Search Parameters

/// GitHub 레포지토리 검색 파라미터
public struct GitHubSearchParameters: Equatable, Sendable {
  public let query: String
  public let sort: GitHubSearchSort
  public let order: GitHubSearchOrder
  public let page: Int
  public let perPage: Int
  
  public init(
    query: String,
    sort: GitHubSearchSort = .stars,
    order: GitHubSearchOrder = .desc,
    page: Int = 1,
    perPage: Int = 30
  ) {
    self.query = query
    self.sort = sort
    self.order = order
    self.page = max(1, page)
    self.perPage = min(max(1, perPage), 100) // GitHub API 제한: 1-100
  }
}

/// GitHub 검색 정렬 옵션
public enum GitHubSearchSort: String, CaseIterable, Sendable {
  case stars
  case forks
  case helpWantedIssues = "help-wanted-issues"
  case updated
  
  public var displayName: String {
    switch self {
    case .stars: return "스타 수"
    case .forks: return "포크 수"
    case .helpWantedIssues: return "도움 요청 이슈"
    case .updated: return "업데이트 시간"
    }
  }
}

/// GitHub 검색 정렬 순서
public enum GitHubSearchOrder: String, CaseIterable, Sendable {
  case asc
  case desc
  
  public var displayName: String {
    switch self {
    case .asc: return "오름차순"
    case .desc: return "내림차순"
    }
  }
}

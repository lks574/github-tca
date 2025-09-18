import Foundation

// MARK: - GitHub Service Protocol

/// GitHub API 서비스 프로토콜
public protocol GitHubServiceProtocol: Sendable {
  
  /// 레포지토리 검색
  /// - Parameter parameters: 검색 파라미터
  /// - Returns: 검색 결과
  func searchRepositories(parameters: GitHubSearchParameters) async throws -> GitHubSearchResponse
  
  /// 특정 레포지토리 정보 조회
  /// - Parameters:
  ///   - owner: 소유자명
  ///   - repo: 레포지토리명
  /// - Returns: 레포지토리 정보
  func getRepository(owner: String, repo: String) async throws -> GitHubRepository
  
  /// 사용자 정보 조회
  /// - Parameter username: 사용자명
  /// - Returns: 사용자 정보
  func getUser(username: String) async throws -> GitHubUser
  
  /// 현재 인증된 사용자 정보 조회
  /// - Returns: 현재 사용자 정보
  func getCurrentUser() async throws -> GitHubUser
  
  /// 사용자의 리포지토리 목록 조회
  /// - Parameters:
  ///   - username: 사용자명
  ///   - page: 페이지 번호
  ///   - perPage: 페이지당 항목 수
  /// - Returns: 리포지토리 목록
  func getUserRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository]
  
  /// 사용자가 별표 표시한 리포지토리 목록 조회
  /// - Parameters:
  ///   - username: 사용자명
  ///   - page: 페이지 번호
  ///   - perPage: 페이지당 항목 수
  /// - Returns: 별표 표시한 리포지토리 목록
  func getUserStarredRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository]
}

// MARK: - GitHub Service Implementation

/// GitHub API 서비스 구현체
public actor GitHubService: GitHubServiceProtocol {
  
  // MARK: - Properties
  
  private let session: URLSession
  private let baseURL: String
  private let apiVersion: String
  private let userAgent: String
  
  // MARK: - Initialization
  
  public init(
    session: URLSession = .shared,
    baseURL: String = "https://api.github.com",
    apiVersion: String = "2022-11-28",
    userAgent: String = "GitHub-TCA-iOS-App"
  ) {
    var configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    
    self.session = URLSession(configuration: configuration)
    self.baseURL = baseURL
    self.apiVersion = apiVersion
    self.userAgent = userAgent
  }
  
  // MARK: - Public Methods
  
  public func searchRepositories(parameters: GitHubSearchParameters) async throws -> GitHubSearchResponse {
    // 검색어 유효성 검사
    let trimmedQuery = parameters.query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedQuery.isEmpty else {
      throw GitHubError.emptyQuery
    }
    
    // URL 구성
    guard var components = URLComponents(string: "\(baseURL)/search/repositories") else {
      throw GitHubError.invalidURL
    }
    
    components.queryItems = [
      URLQueryItem(name: "q", value: trimmedQuery),
      URLQueryItem(name: "sort", value: parameters.sort.rawValue),
      URLQueryItem(name: "order", value: parameters.order.rawValue),
      URLQueryItem(name: "page", value: "\(parameters.page)"),
      URLQueryItem(name: "per_page", value: "\(parameters.perPage)")
    ]
    
    guard let url = components.url else {
      throw GitHubError.invalidURL
    }
    
    return try await performRequest(url: url, responseType: GitHubSearchResponse.self)
  }
  
  public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
    // 파라미터 유효성 검사
    guard !owner.isEmpty, !repo.isEmpty else {
      throw GitHubError.invalidQuery
    }
    
    guard let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)") else {
      throw GitHubError.invalidURL
    }
    
    return try await performRequest(url: url, responseType: GitHubRepository.self)
  }
  
  public func getUser(username: String) async throws -> GitHubUser {
    // 파라미터 유효성 검사
    guard !username.isEmpty else {
      throw GitHubError.invalidQuery
    }
    
    guard let url = URL(string: "\(baseURL)/users/\(username)") else {
      throw GitHubError.invalidURL
    }
    
    return try await performRequest(url: url, responseType: GitHubUser.self)
  }
  
  public func getCurrentUser() async throws -> GitHubUser {
    guard let url = URL(string: "\(baseURL)/user") else {
      throw GitHubError.invalidURL
    }
    
    return try await performAuthenticatedRequest(url: url, responseType: GitHubUser.self)
  }
  
  public func getUserRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository] {
    // 파라미터 유효성 검사
    guard !username.isEmpty else {
      throw GitHubError.invalidQuery
    }
    
    guard let url = URL(string: "\(baseURL)/users/\(username)/repos?page=\(page)&per_page=\(perPage)&sort=updated") else {
      throw GitHubError.invalidURL
    }
    
    return try await performRequest(url: url, responseType: [GitHubRepository].self)
  }
  
  public func getUserStarredRepositories(username: String, page: Int, perPage: Int) async throws -> [GitHubRepository] {
    // 파라미터 유효성 검사
    guard !username.isEmpty else {
      throw GitHubError.invalidQuery
    }
    
    guard let url = URL(string: "\(baseURL)/users/\(username)/starred?page=\(page)&per_page=\(perPage)&sort=updated") else {
      throw GitHubError.invalidURL
    }
    
    return try await performRequest(url: url, responseType: [GitHubRepository].self)
  }
  
  // MARK: - Private Methods
  
  private func performRequest<T: Decodable>(
    url: URL,
    responseType: T.Type
  ) async throws -> T {
    
    // 요청 생성
    var request = URLRequest(url: url)
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    // 네트워크 요청 수행
    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(for: request)
    } catch let urlError as URLError {
      throw GitHubError.from(urlError: urlError)
    } catch {
      throw GitHubError.networkError(error.localizedDescription)
    }
    
    // HTTP 응답 검증
    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubError.invalidResponse
    }
    
    // 상태 코드 확인
    guard 200...299 ~= httpResponse.statusCode else {
      throw GitHubError.from(httpStatusCode: httpResponse.statusCode, data: data)
    }
    
    // 데이터 존재 확인
    guard !data.isEmpty else {
      throw GitHubError.noData
    }
    
    // JSON 디코딩
    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(T.self, from: data)
    } catch {
      throw GitHubError.decodingError(error.localizedDescription)
    }
  }
  
  private func performAuthenticatedRequest<T: Decodable>(
    url: URL,
    responseType: T.Type
  ) async throws -> T {
    
    // 요청 생성
    var request = URLRequest(url: url)
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    // 인증 토큰 추가 (실제 구현에서는 Keychain에서 가져와야 함)
    if let token = UserDefaults.standard.string(forKey: "github_access_token") {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    // 네트워크 요청 수행
    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(for: request)
    } catch let urlError as URLError {
      throw GitHubError.from(urlError: urlError)
    } catch {
      throw GitHubError.networkError(error.localizedDescription)
    }
    
    // HTTP 응답 검증
    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubError.invalidResponse
    }
    
    // 상태 코드 확인
    guard 200...299 ~= httpResponse.statusCode else {
      throw GitHubError.from(httpStatusCode: httpResponse.statusCode, data: data)
    }
    
    // 데이터 존재 확인
    guard !data.isEmpty else {
      throw GitHubError.noData
    }
    
    // JSON 디코딩
    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(T.self, from: data)
    } catch {
      throw GitHubError.decodingError(error.localizedDescription)
    }
  }
}

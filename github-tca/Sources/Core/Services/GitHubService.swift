import Foundation
import ComposableArchitecture
import SwiftUI

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
  
  /// 현재 사용자의 리포지토리 목록 조회 (인증된 사용자)
  /// - Parameters:
  ///   - page: 페이지 번호
  ///   - perPage: 페이지당 항목 수
  ///   - type: 리포지토리 타입 (all, owner, member 등)
  ///   - sort: 정렬 방식 (updated, created, pushed, full_name)
  /// - Returns: 현재 사용자의 리포지토리 목록
  func getCurrentUserRepositories(page: Int, perPage: Int, type: String, sort: String) async throws -> [ProfileModel.RepositoryItem]
  
  /// 현재 사용자의 리포지토리 검색
  /// - Parameter query: 검색 쿼리
  /// - Returns: 검색된 리포지토리 목록
  func searchUserRepositories(query: String) async throws -> [ProfileModel.RepositoryItem]
}

// MARK: - GitHub Service Implementation

/// GitHub API 서비스 구현체
public actor GitHubService: GitHubServiceProtocol {
  
  // MARK: - Properties
  
  private let session: URLSession
  private let baseURL: String
  private let apiVersion: String
  private let userAgent: String
  private let authClient: GitHubAuthClient
  
  // MARK: - Initialization
  
  public init(
    authClient: GitHubAuthClient,
    session: URLSession = .shared,
    baseURL: String = "https://api.github.com",
    apiVersion: String = "2022-11-28",
    userAgent: String = "GitHub-TCA-iOS-App"
  ) {
    var configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    
    self.authClient = authClient
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
    
    // 인증 토큰 추가 (Keychain에서 가져오기)
    do {
      if let token = try await authClient.getAccessToken() {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    } catch {
      // 토큰 가져오기 실패시 로그만 출력하고 계속 진행 (공개 API는 토큰 없이도 접근 가능)
      print("⚠️ 토큰 가져오기 실패: \(error.localizedDescription)")
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
  
  /// 현재 사용자의 리포지토리 목록 조회 (인증된 사용자)
  public func getCurrentUserRepositories(page: Int, perPage: Int, type: String, sort: String) async throws -> [ProfileModel.RepositoryItem] {
    var urlComponents = URLComponents(string: "\(baseURL)/user/repos")!
    urlComponents.queryItems = [
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "per_page", value: "\(perPage)"),
      URLQueryItem(name: "type", value: type),
      URLQueryItem(name: "sort", value: sort),
      URLQueryItem(name: "direction", value: "desc")
    ]

    let repositories = try await performRequest(url: urlComponents.url!, responseType: [GitHubRepository].self)

    // GitHubRepository를 ProfileModel.RepositoryItem으로 변환
    return repositories.map { repo in
      ProfileModel.RepositoryItem(
        id: repo.id,
        name: repo.name,
        fullName: repo.fullName,
        description: repo.description,
        language: repo.language,
        languageColor: colorForLanguage(repo.language),
        starCount: repo.stargazersCount,
        forkCount: repo.forksCount,
        isPrivate: repo.isPrivate,
        updatedAt: formatDate(repo.updatedAt)
      )
    }
  }
  
  /// 현재 사용자의 리포지토리 검색
  public func searchUserRepositories(query: String) async throws -> [ProfileModel.RepositoryItem] {
    // 현재 사용자 정보 먼저 가져오기
    let currentUser = try await getCurrentUser()
    
    // 사용자의 리포지토리 중에서 검색
    var urlComponents = URLComponents(string: "\(baseURL)/search/repositories")!
    urlComponents.queryItems = [
      URLQueryItem(name: "q", value: "\(query) user:\(currentUser.login)"),
      URLQueryItem(name: "sort", value: "updated"),
      URLQueryItem(name: "order", value: "desc"),
      URLQueryItem(name: "per_page", value: "50")
    ]
    
    let searchResponse = try await performRequest(url: urlComponents.url!, responseType: GitHubSearchResponse.self)

    // GitHubRepository를 ProfileModel.RepositoryItem으로 변환
    return searchResponse.items.map { repo in
      ProfileModel.RepositoryItem(
        id: repo.id,
        name: repo.name,
        fullName: repo.fullName,
        description: repo.description,
        language: repo.language,
        languageColor: colorForLanguage(repo.language),
        starCount: repo.stargazersCount,
        forkCount: repo.forksCount,
        isPrivate: repo.isPrivate,
        updatedAt: formatDate(repo.updatedAt)
      )
    }
  }
  
  // MARK: - Helper Methods
  
  /// 프로그래밍 언어에 따른 색상 반환
  private func colorForLanguage(_ language: String?) -> Color? {
    guard let language = language else { return nil }
    
    switch language.lowercased() {
    case "swift": return Color(red: 0.98, green: 0.36, blue: 0.22)
    case "javascript": return Color(red: 0.94, green: 0.85, blue: 0.29)
    case "typescript": return Color(red: 0.18, green: 0.36, blue: 0.73)
    case "python": return Color(red: 0.22, green: 0.42, blue: 0.69)
    case "java": return Color(red: 0.89, green: 0.27, blue: 0.05)
    case "kotlin": return Color(red: 0.46, green: 0.44, blue: 0.87)
    case "go": return Color(red: 0.22, green: 0.67, blue: 0.73)
    case "rust": return Color(red: 0.87, green: 0.36, blue: 0.09)
    case "c++", "cpp": return Color(red: 0.95, green: 0.26, blue: 0.38)
    case "c": return Color(red: 0.33, green: 0.42, blue: 0.53)
    case "html": return Color(red: 0.89, green: 0.29, blue: 0.19)
    case "css": return Color(red: 0.09, green: 0.45, blue: 0.8)
    case "dart": return Color(red: 0.0, green: 0.66, blue: 0.93)
    case "ruby": return Color(red: 0.8, green: 0.09, blue: 0.22)
    case "php": return Color(red: 0.31, green: 0.4, blue: 0.68)
    default: return Color.githubTertiaryText
    }
  }
  
  /// 날짜를 포맷팅
  private func formatDate(_ dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: dateString) else {
      return dateString
    }
    
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.dateTimeStyle = .named
    return relativeFormatter.localizedString(for: date, relativeTo: Date())
  }
}

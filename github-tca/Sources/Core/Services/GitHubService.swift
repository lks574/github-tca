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
  
  // MARK: - Notification Operations
  
  /// 현재 사용자의 알림 목록 조회
  /// - Parameters:
  ///   - all: 모든 알림 여부
  ///   - participating: 참여 중인 알림만 여부
  ///   - since: 특정 시간 이후의 알림
  ///   - before: 특정 시간 이전의 알림
  ///   - page: 페이지 번호
  ///   - perPage: 페이지당 항목 수
  /// - Returns: 알림 목록
  func getNotifications(all: Bool, participating: Bool, since: String?, before: String?, page: Int, perPage: Int) async throws -> [GitHubNotification]
  
  /// 특정 알림을 읽음으로 표시
  /// - Parameter threadId: 알림 스레드 ID
  func markNotificationAsRead(threadId: String) async throws -> Void
  
  /// 모든 알림을 읽음으로 표시
  /// - Parameter lastReadAt: 마지막 읽은 시간
  func markAllNotificationsAsRead(lastReadAt: String?) async throws -> Void
  
  /// 특정 리포지토리의 알림을 읽음으로 표시
  /// - Parameters:
  ///   - owner: 리포지토리 소유자
  ///   - repo: 리포지토리 이름
  ///   - lastReadAt: 마지막 읽은 시간
  func markRepositoryNotificationsAsRead(owner: String, repo: String, lastReadAt: String?) async throws -> Void
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
        print("✅ 인증 토큰 확인됨: \(String(token.prefix(10)))...")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      } else {
        print("❌ 인증 토큰이 없습니다!")
        throw GitHubError.authenticationRequired
      }
    } catch {
      print("⚠️ 토큰 가져오기 실패: \(error.localizedDescription)")
      throw GitHubError.authenticationRequired
    }
    
    // 네트워크 요청 수행
    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(for: request)
    } catch let urlError as URLError {
      print("❌ 네트워크 오류: \(urlError)")
      throw GitHubError.from(urlError: urlError)
    } catch {
      print("❌ 요청 실패: \(error)")
      throw GitHubError.networkError(error.localizedDescription)
    }
    
    // HTTP 응답 검증
    guard let httpResponse = response as? HTTPURLResponse else {
      print("❌ 잘못된 HTTP 응답")
      throw GitHubError.invalidResponse
    }
    
    print("📡 HTTP 응답 상태: \(httpResponse.statusCode)")
    
    // 상태 코드 확인
    guard 200...299 ~= httpResponse.statusCode else {
      print("❌ HTTP 오류: \(httpResponse.statusCode)")
      if let errorData = String(data: data, encoding: .utf8) {
        print("❌ 오류 응답: \(errorData)")
      }
      throw GitHubError.from(httpStatusCode: httpResponse.statusCode, data: data)
    }
    
    // 데이터 존재 확인
    guard !data.isEmpty else {
      print("❌ 응답 데이터가 비어있음")
      throw GitHubError.noData
    }
    
    print("✅ 데이터 수신 성공: \(data.count) bytes")
    
    // JSON 디코딩
    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let result = try decoder.decode(T.self, from: data)
      print("✅ JSON 디코딩 성공")
      return result
    } catch {
      print("❌ JSON 디코딩 실패: \(error)")
      if let jsonString = String(data: data, encoding: .utf8) {
        print("❌ JSON 데이터: \(String(jsonString.prefix(500)))")
      }
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

    print("🔗 API 호출: \(urlComponents.url?.absoluteString ?? "invalid URL")")
    
    let repositories: [GitHubRepository] = try await performAuthenticatedRequest(url: urlComponents.url!, responseType: [GitHubRepository].self)

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
    
    let searchResponse: GitHubSearchResponse = try await performAuthenticatedRequest(url: urlComponents.url!, responseType: GitHubSearchResponse.self)

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
  
  // MARK: - Notification Methods
  
  /// 현재 사용자의 알림 목록 조회
  public func getNotifications(all: Bool, participating: Bool, since: String?, before: String?, page: Int, perPage: Int) async throws -> [GitHubNotification] {
    var urlComponents = URLComponents(string: "\(baseURL)/notifications")!
    var queryItems: [URLQueryItem] = [
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "per_page", value: "\(perPage)")
    ]
    
    if all {
      queryItems.append(URLQueryItem(name: "all", value: "true"))
    }
    
    if participating {
      queryItems.append(URLQueryItem(name: "participating", value: "true"))
    }
    
    if let since = since {
      queryItems.append(URLQueryItem(name: "since", value: since))
    }
    
    if let before = before {
      queryItems.append(URLQueryItem(name: "before", value: before))
    }
    
    urlComponents.queryItems = queryItems
    
    print("🔗 알림 API 호출: \(urlComponents.url?.absoluteString ?? "invalid URL")")
    
    let notifications: [GitHubNotification] = try await performAuthenticatedRequest(url: urlComponents.url!, responseType: [GitHubNotification].self)
    
    print("✅ 알림 \(notifications.count)개 수신")
    return notifications
  }
  
  /// 특정 알림을 읽음으로 표시
  public func markNotificationAsRead(threadId: String) async throws -> Void {
    let url = URL(string: "\(baseURL)/notifications/threads/\(threadId)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    // 인증 토큰 추가
    if let token = try await authClient.getAccessToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let (_, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          200...299 ~= httpResponse.statusCode else {
      throw GitHubError.invalidResponse
    }
    
    print("✅ 알림 읽음 처리 완료: \(threadId)")
  }
  
  /// 모든 알림을 읽음으로 표시
  public func markAllNotificationsAsRead(lastReadAt: String?) async throws -> Void {
    let url = URL(string: "\(baseURL)/notifications")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    // 인증 토큰 추가
    if let token = try await authClient.getAccessToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    // 요청 바디에 lastReadAt 포함
    if let lastReadAt = lastReadAt {
      let body = ["last_read_at": lastReadAt]
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    let (_, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          200...299 ~= httpResponse.statusCode else {
      throw GitHubError.invalidResponse
    }
    
    print("✅ 모든 알림 읽음 처리 완료")
  }
  
  /// 특정 리포지토리의 알림을 읽음으로 표시
  public func markRepositoryNotificationsAsRead(owner: String, repo: String, lastReadAt: String?) async throws -> Void {
    let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/notifications")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    // 인증 토큰 추가
    if let token = try await authClient.getAccessToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    // 요청 바디에 lastReadAt 포함
    if let lastReadAt = lastReadAt {
      let body = ["last_read_at": lastReadAt]
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    let (_, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          200...299 ~= httpResponse.statusCode else {
      throw GitHubError.invalidResponse
    }
    
    print("✅ 리포지토리 알림 읽음 처리 완료: \(owner)/\(repo)")
  }
}

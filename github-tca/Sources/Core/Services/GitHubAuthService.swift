import Foundation
import AuthenticationServices
import UIKit

// MARK: - GitHub Auth Service Protocol

/// GitHub 인증 서비스 프로토콜
public protocol GitHubAuthServiceProtocol: Sendable {

  /// OAuth 로그인
  func signIn() async throws -> GitHubAuthResult

  /// 로그아웃
  func signOut() async throws -> Void

  /// 인증 상태 확인
  func isAuthenticated() async throws -> Bool

  /// 액세스 토큰 가져오기
  func getAccessToken() async throws -> String?

  /// 사용자 정보 새로고침
  func refreshUserInfo() async throws -> GitHubUser

  /// 토큰 유효성 검사
  func validateToken() async throws -> Bool
}

// MARK: - GitHub Auth Service Implementation

/// GitHub 인증 서비스 구현체
public actor GitHubAuthService: GitHubAuthServiceProtocol {

  // MARK: - Properties

  private let session: URLSession
  private let baseURL: String
  private let apiVersion: String
  private let userAgent: String
  private let keychain: KeychainService

  // GitHub OAuth 설정
  private let clientId: String
  private let clientSecret: String
  private let redirectUri: String
  private let scope: String

  // MARK: - Initialization

  public init(
    session: URLSession = .shared,
    baseURL: String = GitHubConfig.apiBaseURL,
    apiVersion: String = GitHubConfig.apiVersion,
    userAgent: String = GitHubConfig.userAgent,
    clientId: String = GitHubConfig.clientId,
    clientSecret: String = GitHubConfig.clientSecret,
    redirectUri: String = GitHubConfig.redirectUri,
    scope: String = GitHubConfig.scope
  ) {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

    self.session = URLSession(configuration: configuration)
    self.baseURL = baseURL
    self.apiVersion = apiVersion
    self.userAgent = userAgent
    self.keychain = KeychainService()
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.redirectUri = redirectUri
    self.scope = scope
  }

  // MARK: - Public Methods

  public func signIn() async throws -> GitHubAuthResult {
    // OAuth URL 구성
    guard var components = URLComponents(string: "https://github.com/login/oauth/authorize") else {
      throw GitHubError.invalidURL
    }

    components.queryItems = [
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "redirect_uri", value: redirectUri),
      URLQueryItem(name: "scope", value: scope),
      URLQueryItem(name: "state", value: UUID().uuidString)
    ]

    guard let authURL = components.url else {
      throw GitHubError.invalidURL
    }

    // 실제 OAuth 플로우 (현재는 Mock으로 시뮬레이션)
    return try await performOAuthFlow(authURL: authURL)
  }

  public func signOut() async throws {
    try await keychain.deleteToken()
  }

  public func isAuthenticated() async throws -> Bool {
    let token = try await keychain.getToken()
    return token != nil && !token!.isEmpty
  }

  public func getAccessToken() async throws -> String? {
    return try await keychain.getToken()
  }

  public func refreshUserInfo() async throws -> GitHubUser {
    guard let token = try await keychain.getToken() else {
      throw GitHubError.authenticationRequired
    }

    guard let url = URL(string: "\(baseURL)/user") else {
      throw GitHubError.invalidURL
    }

    return try await performAuthenticatedRequest(url: url, responseType: GitHubUser.self)
  }

  public func validateToken() async throws -> Bool {
    guard let token = try await keychain.getToken(), !token.isEmpty else {
      return false
    }

    do {
      _ = try await refreshUserInfo()
      return true
    } catch {
      // 토큰이 유효하지 않으면 에러 발생
      if let gitHubError = error as? GitHubError {
        switch gitHubError {
        case .unauthorized, .tokenExpired, .tokenInvalid:
          return false
        default:
          throw error
        }
      }
      return false
    }
  }

  // MARK: - Private Methods

  private func performOAuthFlow(authURL: URL) async throws -> GitHubAuthResult {
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        let authSession = ASWebAuthenticationSession(
          url: authURL,
          callbackURLScheme: "github-tca"
        ) { [weak self] callbackURL, error in
          Task {
            do {
              if let error = error {
                if let authError = error as? ASWebAuthenticationSessionError {
                  switch authError.code {
                  case .canceledLogin:
                    continuation.resume(throwing: GitHubError.oauthCancelled)
                  default:
                    continuation.resume(throwing: GitHubError.oauthFailed(authError.localizedDescription))
                  }
                } else {
                  continuation.resume(throwing: GitHubError.oauthFailed(error.localizedDescription))
                }
                return
              }

              guard let callbackURL = callbackURL else {
                continuation.resume(throwing: GitHubError.oauthFailed("콜백 URL이 없습니다."))
                return
              }

              let authCode = try await self?.extractAuthCode(from: callbackURL)
              guard let authCode = authCode else {
                continuation.resume(throwing: GitHubError.oauthFailed("인증 코드를 추출할 수 없습니다."))
                return
              }

              let accessToken = try await self?.exchangeCodeForToken(authCode: authCode)
              guard let accessToken = accessToken else {
                continuation.resume(throwing: GitHubError.oauthFailed("액세스 토큰을 얻을 수 없습니다."))
                return
              }

              // 토큰을 키체인에 저장
              try await self?.keychain.store(token: accessToken)

              // 사용자 정보 가져오기
              let user = try await self?.fetchUserInfo(accessToken: accessToken)
              guard let user = user else {
                continuation.resume(throwing: GitHubError.oauthFailed("사용자 정보를 가져올 수 없습니다."))
                return
              }

              let result = GitHubAuthResult(accessToken: accessToken, user: user)
              continuation.resume(returning: result)

            } catch {
              continuation.resume(throwing: error)
            }
          }
        }

        authSession.presentationContextProvider = AuthPresentationContextProvider.shared
        authSession.prefersEphemeralWebBrowserSession = false
        authSession.start()
      }
    }
  }

  private func extractAuthCode(from url: URL) async throws -> String {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else {
      throw GitHubError.oauthFailed("콜백 URL을 파싱할 수 없습니다.")
    }

    // 에러 확인
    if let errorItem = queryItems.first(where: { $0.name == "error" }),
       let errorValue = errorItem.value {
      throw GitHubError.oauthFailed("GitHub OAuth 오류: \(errorValue)")
    }

    // 인증 코드 추출
    guard let codeItem = queryItems.first(where: { $0.name == "code" }),
          let authCode = codeItem.value else {
      throw GitHubError.oauthFailed("인증 코드가 콜백 URL에 없습니다.")
    }

    return authCode
  }

  private func exchangeCodeForToken(authCode: String) async throws -> String {
    guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
      throw GitHubError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

    let requestBody = [
      "client_id": clientId,
      "client_secret": clientSecret,
      "code": authCode,
      "redirect_uri": redirectUri
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          200...299 ~= httpResponse.statusCode else {
      throw GitHubError.oauthFailed("토큰 교환 요청이 실패했습니다.")
    }

    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw GitHubError.decodingError("토큰 응답을 파싱할 수 없습니다.")
    }

    if let error = json["error"] as? String {
      let errorDescription = json["error_description"] as? String ?? "알 수 없는 오류"
      throw GitHubError.oauthFailed("토큰 교환 오류: \(error) - \(errorDescription)")
    }

    guard let accessToken = json["access_token"] as? String else {
      throw GitHubError.oauthFailed("액세스 토큰이 응답에 없습니다.")
    }

    return accessToken
  }

  private func fetchUserInfo(accessToken: String) async throws -> GitHubUser {
    guard let url = URL(string: "\(baseURL)/user") else {
      throw GitHubError.invalidURL
    }

    var request = URLRequest(url: url)
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubError.invalidResponse
    }

    guard 200...299 ~= httpResponse.statusCode else {
      throw GitHubError.from(httpStatusCode: httpResponse.statusCode, data: data)
    }

    guard !data.isEmpty else {
      throw GitHubError.noData
    }

    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(GitHubUser.self, from: data)
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

    // 인증 토큰 추가
    guard let token = try await keychain.getToken() else {
      throw GitHubError.authenticationRequired
    }
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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

// MARK: - Presentation Context Provider

@MainActor
final class AuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
  static let shared = AuthPresentationContextProvider()
  private override init() { super.init() }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    if let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first {
      if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
        return keyWindow
      }
      // Fall back to the first available window in the scene
      if let anyWindow = windowScene.windows.first {
        return anyWindow
      }
    }
    if let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first {
      return UIWindow(windowScene: windowScene)
    }
    // Final fallback
    return UIWindow()
  }
}

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
}


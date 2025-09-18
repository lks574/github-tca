import Foundation
import Security

// MARK: - Keychain Service Protocol

/// 키체인 서비스 프로토콜
public protocol KeychainServiceProtocol: Sendable {
  
  /// 토큰 저장
  func store(token: String) async throws
  
  /// 토큰 가져오기
  func getToken() async throws -> String?
  
  /// 토큰 삭제
  func deleteToken() async throws
  
  /// 토큰 존재 여부 확인
  func hasToken() async throws -> Bool
}

// MARK: - Keychain Service Implementation

/// 키체인 서비스 구현체
public actor KeychainService: KeychainServiceProtocol {
  
  // MARK: - Properties
  
  private let service: String
  private let account: String
  
  // MARK: - Initialization
  
  public init(
    service: String = "com.github.tca.app",
    account: String = "github_access_token"
  ) {
    self.service = service
    self.account = account
  }
  
  // MARK: - Public Methods
  
  public func store(token: String) async throws {
    // 실제 구현에서는 Keychain에 토큰을 안전하게 저장
    // 현재는 UserDefaults로 시뮬레이션 (보안상 권장하지 않음)
    UserDefaults.standard.set(token, forKey: account)
  }
  
  public func getToken() async throws -> String? {
    // 실제 구현에서는 Keychain에서 토큰을 안전하게 가져옴
    // 현재는 UserDefaults에서 가져옴 (보안상 권장하지 않음)
    return UserDefaults.standard.string(forKey: account)
  }
  
  public func deleteToken() async throws {
    // 실제 구현에서는 Keychain에서 토큰을 안전하게 삭제
    // 현재는 UserDefaults에서 삭제 (보안상 권장하지 않음)
    UserDefaults.standard.removeObject(forKey: account)
  }
  
  public func hasToken() async throws -> Bool {
    let token = try await getToken()
    return token != nil && !token!.isEmpty
  }
}

// MARK: - Mock Service for Testing

/// 테스트용 Mock 키체인 서비스
public struct MockKeychainService: KeychainServiceProtocol {
  
  private var storedToken: String?
  
  public init(storedToken: String? = nil) {
    self.storedToken = storedToken
  }
  
  public func store(token: String) async throws {
    // Mock에서는 메모리에만 저장
  }
  
  public func getToken() async throws -> String? {
    return storedToken
  }
  
  public func deleteToken() async throws {
    // Mock에서는 아무것도 하지 않음
  }
  
  public func hasToken() async throws -> Bool {
    return storedToken != nil && !storedToken!.isEmpty
  }
}

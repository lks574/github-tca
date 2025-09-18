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
    service: String = GitHubConfig.keychainService,
    account: String = GitHubConfig.keychainAccount
  ) {
    self.service = service
    self.account = account
  }
  
  // MARK: - Public Methods
  
  public func store(token: String) async throws {
    let tokenData = token.data(using: .utf8)!
    
    // 기존 항목 삭제 (있다면)
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
    SecItemDelete(deleteQuery as CFDictionary)
    
    // 새 항목 추가
    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: tokenData,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    
    let status = SecItemAdd(addQuery as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw GitHubError.unknown("키체인 저장 실패: \(status)")
    }
  }
  
  public func getToken() async throws -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess else {
      if status == errSecItemNotFound {
        return nil
      }
      throw GitHubError.unknown("키체인 읽기 실패: \(status)")
    }
    
    guard let tokenData = result as? Data,
          let token = String(data: tokenData, encoding: .utf8) else {
      throw GitHubError.unknown("키체인 데이터 변환 실패")
    }
    
    return token
  }
  
  public func deleteToken() async throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw GitHubError.unknown("키체인 삭제 실패: \(status)")
    }
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

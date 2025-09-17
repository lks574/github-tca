import Foundation

// MARK: - Keychain Service

final class KeychainService: Sendable {

  let service = "com.github.tca.app"
  let account = "github_access_token"

  func store(token: String) async throws {
    // 실제 구현에서는 Keychain에 토큰을 안전하게 저장
    UserDefaults.standard.set(token, forKey: "github_access_token")
  }

  func getToken() async throws -> String? {
    // 실제 구현에서는 Keychain에서 토큰을 안전하게 가져옴
    return UserDefaults.standard.string(forKey: "github_access_token")
  }

  func deleteToken() async throws {
    // 실제 구현에서는 Keychain에서 토큰을 안전하게 삭제
    UserDefaults.standard.removeObject(forKey: "github_access_token")
  }
}

import Foundation

// MARK: - GitHub Configuration

/// GitHub OAuth 설정
public struct GitHubConfig {
  
  // MARK: - OAuth Settings
  
  /// GitHub OAuth Client ID
  /// 실제 사용 시 GitHub에서 발급받은 Client ID로 교체 필요
  public static let clientId: String = {
    // 1순위: Xcode 환경 변수에서 가져오기
    if let clientId = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"], !clientId.isEmpty {
      return clientId
    }
    
    // 2순위: Info.plist에서 가져오기
    if let clientId = Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String, !clientId.isEmpty {
      return clientId
    }
    
    // 3순위: 개발용 기본값 (환경 변수가 설정되지 않은 경우만 사용)
    print("⚠️ GITHUB_CLIENT_ID 환경 변수가 설정되지 않았습니다. 기본값을 사용합니다.")
    return "YOUR_GITHUB_CLIENT_ID"
  }()
  
  /// GitHub OAuth Client Secret
  /// 실제 사용 시 GitHub에서 발급받은 Client Secret으로 교체 필요
  /// 보안상 클라이언트에 하드코딩하지 않는 것이 좋음
  public static let clientSecret: String = {
    // 1순위: Xcode 환경 변수에서 가져오기
    if let clientSecret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"], !clientSecret.isEmpty {
      return clientSecret
    }
    
    // 2순위: Info.plist에서 가져오기
    if let clientSecret = Bundle.main.infoDictionary?["GITHUB_CLIENT_SECRET"] as? String, !clientSecret.isEmpty {
      return clientSecret
    }
    
    // 3순위: 개발용 기본값 (환경 변수가 설정되지 않은 경우만 사용)
    print("⚠️ GITHUB_CLIENT_SECRET 환경 변수가 설정되지 않았습니다. 기본값을 사용합니다.")
    return "YOUR_GITHUB_CLIENT_SECRET"
  }()
  
  /// OAuth Redirect URI
  public static let redirectUri = "github-tca://oauth/callback"
  
  /// OAuth Scope
  public static let scope = "user:email,repo,read:org"
  
  // MARK: - API Settings
  
  /// GitHub API Base URL
  public static let apiBaseURL = "https://api.github.com"
  
  /// GitHub API Version
  public static let apiVersion = "2022-11-28"
  
  /// User Agent for API requests
  public static let userAgent = "GitHub-TCA-iOS-App/1.0"
  
  // MARK: - Keychain Settings
  
  /// Keychain Service Name
  public static let keychainService = "com.sro.github-tca"
  
  /// Keychain Account Name for Access Token
  public static let keychainAccount = "github_access_token"
}

// MARK: - Development Mode

#if DEBUG
extension GitHubConfig {
  
  /// 개발 모드 여부
  public static let isDevelopmentMode = true
  
  /// Mock 데이터 사용 여부
  public static let useMockData = true
  
  /// 로깅 활성화 여부
  public static let isLoggingEnabled = true
  
  /// 설정 값들을 디버그 출력
  public static func printDebugInfo() {
    print("🔧 GitHub Config Debug Info:")
    print("  📱 Client ID: \(clientId.prefix(10))...")
    print("  🔑 Client Secret: \(clientSecret.prefix(10))...")
    print("  🔗 Redirect URI: \(redirectUri)")
    print("  🌐 API Base URL: \(apiBaseURL)")
    
    // 환경 변수 확인
    let envClientId = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"]
    let envClientSecret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"]
    print("  🌍 Env Client ID: \(envClientId != nil ? "✅ Set" : "❌ Not set")")
    print("  🌍 Env Client Secret: \(envClientSecret != nil ? "✅ Set" : "❌ Not set")")
    
    // Info.plist 확인
    let plistClientId = Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String
    let plistClientSecret = Bundle.main.infoDictionary?["GITHUB_CLIENT_SECRET"] as? String
    print("  📋 Plist Client ID: \(plistClientId != nil ? "✅ Set" : "❌ Not set")")
    print("  📋 Plist Client Secret: \(plistClientSecret != nil ? "✅ Set" : "❌ Not set")")
  }
}
#else
extension GitHubConfig {
  
  /// 개발 모드 여부
  public static let isDevelopmentMode = false
  
  /// Mock 데이터 사용 여부
  public static let useMockData = false
  
  /// 로깅 활성화 여부
  public static let isLoggingEnabled = false
}
#endif

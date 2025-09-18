import Foundation

// MARK: - GitHub Configuration

/// GitHub OAuth 설정
public struct GitHubConfig {
  
  // MARK: - OAuth Settings
  
  /// GitHub OAuth Client ID
  /// 실제 사용 시 GitHub에서 발급받은 Client ID로 교체 필요
  public static let clientId: String = {
    // 환경 변수에서 가져오거나 Info.plist에서 가져올 수 있음
    if let clientId = Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String {
      return clientId
    }
    
    // 개발용 기본값 (실제 운영에서는 사용하지 말 것)
    return "YOUR_GITHUB_CLIENT_ID"
  }()
  
  /// GitHub OAuth Client Secret
  /// 실제 사용 시 GitHub에서 발급받은 Client Secret으로 교체 필요
  /// 보안상 클라이언트에 하드코딩하지 않는 것이 좋음
  public static let clientSecret: String = {
    if let clientSecret = Bundle.main.infoDictionary?["GITHUB_CLIENT_SECRET"] as? String {
      return clientSecret
    }
    
    // 개발용 기본값 (실제 운영에서는 사용하지 말 것)
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

import Foundation

// MARK: - GitHub Client Error

/// GitHub API 클라이언트 에러 타입
public enum GitHubError: Error, Equatable, Sendable {
  
  // MARK: - Request Errors
  case invalidURL
  case invalidQuery
  case emptyQuery
  
  // MARK: - Network Errors
  case networkError(String)
  case noInternetConnection
  case timeout
  case serverUnavailable
  
  // MARK: - API Errors
  case unauthorized
  case forbidden
  case notFound
  case rateLimitExceeded
  case validationFailed(String)
  case internalServerError
  
  // MARK: - Response Errors
  case noData
  case invalidResponse
  case decodingError(String)
  
  // MARK: - Unknown Error
  case unknown(String)
  
  // MARK: - Localized Description
  public var localizedDescription: String {
    switch self {
    // Request Errors
    case .invalidURL:
      return "잘못된 URL입니다."
    case .invalidQuery:
      return "잘못된 검색어입니다."
    case .emptyQuery:
      return "검색어를 입력해주세요."
    
    // Network Errors
    case .networkError(let message):
      return "네트워크 오류가 발생했습니다: \(message)"
    case .noInternetConnection:
      return "인터넷 연결을 확인해주세요."
    case .timeout:
      return "요청 시간이 초과되었습니다."
    case .serverUnavailable:
      return "서버에 일시적으로 접근할 수 없습니다."
    
    // API Errors
    case .unauthorized:
      return "인증이 필요합니다."
    case .forbidden:
      return "접근 권한이 없습니다."
    case .notFound:
      return "요청한 리소스를 찾을 수 없습니다."
    case .rateLimitExceeded:
      return "API 호출 한도를 초과했습니다. 잠시 후 다시 시도해주세요."
    case .validationFailed(let message):
      return "요청 검증에 실패했습니다: \(message)"
    case .internalServerError:
      return "서버 내부 오류가 발생했습니다."
    
    // Response Errors
    case .noData:
      return "응답 데이터가 없습니다."
    case .invalidResponse:
      return "잘못된 응답 형식입니다."
    case .decodingError(let message):
      return "데이터 파싱 중 오류가 발생했습니다: \(message)"
    
    // Unknown Error
    case .unknown(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    }
  }
  
  // MARK: - Error Code
  public var errorCode: String {
    switch self {
    case .invalidURL: return "INVALID_URL"
    case .invalidQuery: return "INVALID_QUERY"
    case .emptyQuery: return "EMPTY_QUERY"
    case .networkError: return "NETWORK_ERROR"
    case .noInternetConnection: return "NO_INTERNET"
    case .timeout: return "TIMEOUT"
    case .serverUnavailable: return "SERVER_UNAVAILABLE"
    case .unauthorized: return "UNAUTHORIZED"
    case .forbidden: return "FORBIDDEN"
    case .notFound: return "NOT_FOUND"
    case .rateLimitExceeded: return "RATE_LIMIT_EXCEEDED"
    case .validationFailed: return "VALIDATION_FAILED"
    case .internalServerError: return "INTERNAL_SERVER_ERROR"
    case .noData: return "NO_DATA"
    case .invalidResponse: return "INVALID_RESPONSE"
    case .decodingError: return "DECODING_ERROR"
    case .unknown: return "UNKNOWN"
    }
  }
  
  // MARK: - Is Recoverable
  public var isRecoverable: Bool {
    switch self {
    case .invalidURL, .invalidQuery, .emptyQuery:
      return false
    case .networkError, .noInternetConnection, .timeout, .serverUnavailable:
      return true
    case .unauthorized, .forbidden, .notFound:
      return false
    case .rateLimitExceeded:
      return true
    case .validationFailed, .internalServerError:
      return false
    case .noData, .invalidResponse, .decodingError:
      return false
    case .unknown:
      return false
    }
  }
  
  // MARK: - Should Retry
  public var shouldRetry: Bool {
    switch self {
    case .timeout, .serverUnavailable, .rateLimitExceeded:
      return true
    default:
      return false
    }
  }
}

// MARK: - HTTP Status Code Mapping
extension GitHubError {
  
  /// HTTP 상태 코드로부터 GitHubError 생성
  public static func from(httpStatusCode: Int, data: Data? = nil) -> GitHubError {
    switch httpStatusCode {
    case 400:
      return .invalidQuery
    case 401:
      return .unauthorized
    case 403:
      if let data = data,
         let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let message = json["message"] as? String,
         message.contains("rate limit") {
        return .rateLimitExceeded
      }
      return .forbidden
    case 404:
      return .notFound
    case 422:
      if let data = data,
         let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
         let message = json["message"] as? String {
        return .validationFailed(message)
      }
      return .validationFailed("입력값이 유효하지 않습니다.")
    case 500...599:
      return .internalServerError
    case 503:
      return .serverUnavailable
    default:
      return .unknown("HTTP \(httpStatusCode)")
    }
  }
}

// MARK: - URLError Mapping
extension GitHubError {
  
  /// URLError로부터 GitHubError 생성
  public static func from(urlError: URLError) -> GitHubError {
    switch urlError.code {
    case .notConnectedToInternet, .networkConnectionLost:
      return .noInternetConnection
    case .timedOut:
      return .timeout
    case .cannotFindHost, .cannotConnectToHost:
      return .serverUnavailable
    case .badURL:
      return .invalidURL
    default:
      return .networkError(urlError.localizedDescription)
    }
  }
}

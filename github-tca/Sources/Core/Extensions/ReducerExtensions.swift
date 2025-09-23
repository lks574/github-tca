import ComposableArchitecture
import Foundation

// MARK: - 표준화된 에러 처리 Extension
extension Reducer {
  
  /// 표준화된 에러 처리 - 로딩 상태 정리 + 에러 메시지 설정
  static func handleError<S>(
    _ state: inout S,
    error: Error,
    loadingKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>
  ) where S: Equatable {
    // 로딩 상태 정리
    state[keyPath: loadingKeyPath] = false
    
    // GitHubError 우선 처리, 일반 Error는 fallback
    if let gitHubError = error as? GitHubError {
      state[keyPath: errorKeyPath] = gitHubError.localizedDescription
      print("❌ GitHubError: \(gitHubError.localizedDescription)")
    } else {
      state[keyPath: errorKeyPath] = error.localizedDescription
      print("❌ 일반 에러: \(error.localizedDescription)")
    }
  }
  
  /// 표준화된 로딩 시작 - 로딩 상태 설정 + 에러 메시지 클리어
  static func startLoading<S>(
    _ state: inout S,
    loadingKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>
  ) where S: Equatable {
    state[keyPath: loadingKeyPath] = true
    state[keyPath: errorKeyPath] = nil
  }
  
  /// 표준화된 성공 처리 - 로딩 상태 정리 + 에러 메시지 클리어
  static func handleSuccess<S>(
    _ state: inout S,
    loadingKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>
  ) where S: Equatable {
    state[keyPath: loadingKeyPath] = false
    state[keyPath: errorKeyPath] = nil
  }
  
  /// 표준화된 페이지네이션 에러 처리 - loadMore 등에 사용
  static func handlePaginationError<S>(
    _ state: inout S,
    error: Error,
    loadingMoreKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>
  ) where S: Equatable {
    // 페이지네이션 로딩 상태 정리
    state[keyPath: loadingMoreKeyPath] = false
    
    // 에러 메시지 설정 (기존 데이터는 유지)
    if let gitHubError = error as? GitHubError {
      state[keyPath: errorKeyPath] = "추가 데이터 로드 실패: \(gitHubError.localizedDescription)"
      print("❌ 페이지네이션 GitHubError: \(gitHubError.localizedDescription)")
    } else {
      state[keyPath: errorKeyPath] = "추가 데이터 로드 실패: \(error.localizedDescription)"
      print("❌ 페이지네이션 일반 에러: \(error.localizedDescription)")
    }
  }
}

// MARK: - 특화된 에러 처리 메서드들
extension Reducer {
  
  /// 인증 관련 에러 특화 처리
  static func handleAuthError<S>(
    _ state: inout S,
    error: Error,
    loadingKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>,
    isAuthenticatedKeyPath: WritableKeyPath<S, Bool>
  ) where S: Equatable {
    // 기본 에러 처리
    handleError(&state, error: error, loadingKeyPath: loadingKeyPath, errorKeyPath: errorKeyPath)
    
    // 인증 에러인 경우 로그아웃 상태로 변경
    if let gitHubError = error as? GitHubError {
      switch gitHubError {
      case .authenticationRequired, .authenticationFailed, .tokenExpired, .tokenInvalid:
        state[keyPath: isAuthenticatedKeyPath] = false
        state[keyPath: errorKeyPath] = "다시 로그인해주세요."
        print("🔐 인증 에러로 인한 로그아웃: \(gitHubError)")
      default:
        break
      }
    }
  }
  
  /// 네트워크 에러 특화 처리 (재시도 가능 여부 포함)
  static func handleNetworkError<S>(
    _ state: inout S,
    error: Error,
    loadingKeyPath: WritableKeyPath<S, Bool>,
    errorKeyPath: WritableKeyPath<S, String?>,
    canRetryKeyPath: WritableKeyPath<S, Bool>
  ) where S: Equatable {
    // 기본 에러 처리
    handleError(&state, error: error, loadingKeyPath: loadingKeyPath, errorKeyPath: errorKeyPath)
    
    // 재시도 가능 여부 결정
    if let gitHubError = error as? GitHubError {
      state[keyPath: canRetryKeyPath] = gitHubError.shouldRetry
    } else if let urlError = error as? URLError {
      // 네트워크 연결 문제는 재시도 가능
      state[keyPath: canRetryKeyPath] = [.notConnectedToInternet, .networkConnectionLost, .timedOut].contains(urlError.code)
    } else {
      state[keyPath: canRetryKeyPath] = false
    }
  }
}

// MARK: - 에러 상태 표준화를 위한 프로토콜
/// Reducer State가 구현해야 하는 기본 에러 상태 프로토콜
protocol ErrorHandlingState {
  var isLoading: Bool { get set }
  var errorMessage: String? { get set }
}

/// 페이지네이션이 있는 State를 위한 프로토콜
protocol PaginationErrorHandlingState: ErrorHandlingState {
  var isLoadingMore: Bool { get set }
}

/// 인증이 필요한 State를 위한 프로토콜
protocol AuthErrorHandlingState: ErrorHandlingState {
  var isAuthenticated: Bool { get set }
}

/// 네트워크 재시도 기능이 있는 State를 위한 프로토콜
protocol RetryableErrorHandlingState: ErrorHandlingState {
  var canRetry: Bool { get set }
}

// MARK: - 프로토콜 기반 편의 메서드들
extension Reducer {
  
  /// ErrorHandlingState를 구현한 State용 편의 메서드
  static func handleError<S: ErrorHandlingState>(
    _ state: inout S,
    error: Error
  ) where S: Equatable {
    handleError(&state, error: error, loadingKeyPath: \.isLoading, errorKeyPath: \.errorMessage)
  }
  
  /// ErrorHandlingState를 구현한 State용 로딩 시작 편의 메서드
  static func startLoading<S: ErrorHandlingState>(
    _ state: inout S
  ) where S: Equatable {
    startLoading(&state, loadingKeyPath: \.isLoading, errorKeyPath: \.errorMessage)
  }
  
  /// ErrorHandlingState를 구현한 State용 성공 처리 편의 메서드
  static func handleSuccess<S: ErrorHandlingState>(
    _ state: inout S
  ) where S: Equatable {
    handleSuccess(&state, loadingKeyPath: \.isLoading, errorKeyPath: \.errorMessage)
  }
  
  /// PaginationErrorHandlingState를 구현한 State용 페이지네이션 에러 편의 메서드
  static func handlePaginationError<S: PaginationErrorHandlingState>(
    _ state: inout S,
    error: Error
  ) where S: Equatable {
    handlePaginationError(&state, error: error, loadingMoreKeyPath: \.isLoadingMore, errorKeyPath: \.errorMessage)
  }
  
  /// AuthErrorHandlingState를 구현한 State용 인증 에러 편의 메서드
  static func handleAuthError<S: AuthErrorHandlingState>(
    _ state: inout S,
    error: Error
  ) where S: Equatable {
    handleAuthError(&state, error: error, loadingKeyPath: \.isLoading, errorKeyPath: \.errorMessage, isAuthenticatedKeyPath: \.isAuthenticated)
  }
}


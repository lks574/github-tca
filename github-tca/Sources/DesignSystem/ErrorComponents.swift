import SwiftUI
import ComposableArchitecture

// MARK: - 표준화된 에러 UI 컴포넌트들
enum GitHubErrorComponents {
  
  // MARK: - 기본 에러 뷰
  struct ErrorView: View {
    let error: GitHubError
    let onRetry: () -> Void
    
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        // 에러 아이콘
        Image(systemName: error.iconName)
          .font(.system(size: 48))
          .foregroundColor(error.iconColor)
        
        VStack(spacing: GitHubSpacing.sm) {
          Text(error.title)
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
            .multilineTextAlignment(.center)
          
          Text(error.localizedDescription)
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .multilineTextAlignment(.center)
        }
        
        if error.shouldRetry {
          GitHubButton(
            "다시 시도",
            style: .primary
          ) {
            onRetry()
          }
        }
      }
      .padding(.horizontal, GitHubSpacing.xl)
      .padding(.vertical, GitHubSpacing.xxl)
    }
  }
  
  // MARK: - 인라인 에러 뷰 (목록 상단 등에 사용)
  struct InlineErrorView: View {
    let errorMessage: String
    let canRetry: Bool
    let onRetry: () -> Void
    let onDismiss: (() -> Void)?
    
    init(
      errorMessage: String,
      canRetry: Bool = true,
      onRetry: @escaping () -> Void,
      onDismiss: (() -> Void)? = nil
    ) {
      self.errorMessage = errorMessage
      self.canRetry = canRetry
      self.onRetry = onRetry
      self.onDismiss = onDismiss
    }
    
    var body: some View {
      HStack(spacing: GitHubSpacing.md) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: GitHubIconSize.medium))
          .foregroundColor(.githubWarning)
        
        VStack(alignment: .leading, spacing: GitHubSpacing.xs) {
          Text("오류가 발생했습니다")
            .font(.githubSubheadline)
            .fontWeight(.medium)
            .foregroundColor(.githubPrimaryText)
          
          Text(errorMessage)
            .font(.githubFootnote)
            .foregroundColor(.githubSecondaryText)
            .lineLimit(2)
        }
        
        Spacer()
        
        HStack(spacing: GitHubSpacing.sm) {
          if canRetry {
            Button("재시도") {
              onRetry()
            }
            .font(.githubFootnote)
            .foregroundColor(.githubBlue)
          }
          
          if let onDismiss = onDismiss {
            Button {
              onDismiss()
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: GitHubIconSize.small))
                .foregroundColor(.githubSecondaryText)
            }
          }
        }
      }
      .padding(.all, GitHubSpacing.md)
      .background(Color.githubWarningBackground)
      .cornerRadius(GitHubCornerRadius.medium)
      .overlay(
        RoundedRectangle(cornerRadius: GitHubCornerRadius.medium)
          .stroke(Color.githubWarning.opacity(0.3), lineWidth: 1)
      )
    }
  }
  
  // MARK: - 토스트 에러 뷰 (일시적 알림)
  struct ToastErrorView: View {
    let message: String
    let isVisible: Bool
    let onDismiss: () -> Void
    
    var body: some View {
      if isVisible {
        HStack(spacing: GitHubSpacing.sm) {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: GitHubIconSize.medium))
            .foregroundColor(.white)
          
          Text(message)
            .font(.githubSubheadline)
            .foregroundColor(.white)
            .lineLimit(2)
          
          Spacer()
          
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: GitHubIconSize.small))
              .foregroundColor(.white.opacity(0.8))
          }
        }
        .padding(.all, GitHubSpacing.md)
        .background(Color.githubRed)
        .cornerRadius(GitHubCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
          // 5초 후 자동 숨김
          DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            onDismiss()
          }
        }
      }
    }
  }
  
  // MARK: - 네트워크 연결 에러 특화 뷰
  struct NetworkErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Image(systemName: "wifi.slash")
          .font(.system(size: 48))
          .foregroundColor(.githubSecondaryText)
        
        VStack(spacing: GitHubSpacing.sm) {
          Text("연결 상태를 확인해주세요")
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
          
          Text("인터넷 연결을 확인하고 다시 시도해주세요.")
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .multilineTextAlignment(.center)
        }
        
        GitHubButton(
          "다시 시도",
          style: .secondary
        ) {
          onRetry()
        }
      }
      .padding(.horizontal, GitHubSpacing.xl)
      .padding(.vertical, GitHubSpacing.xxl)
    }
  }
  
  // MARK: - 인증 에러 특화 뷰
  struct AuthErrorView: View {
    let onSignIn: () -> Void
    
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Image(systemName: "person.crop.circle.badge.exclamationmark")
          .font(.system(size: 48))
          .foregroundColor(.githubWarning)
        
        VStack(spacing: GitHubSpacing.sm) {
          Text("로그인이 필요합니다")
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
          
          Text("이 기능을 사용하려면 GitHub 계정으로 로그인해주세요.")
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .multilineTextAlignment(.center)
        }
        
        GitHubButton(
          "로그인",
          style: .primary
        ) {
          onSignIn()
        }
      }
      .padding(.horizontal, GitHubSpacing.xl)
      .padding(.vertical, GitHubSpacing.xxl)
    }
  }
  
  // MARK: - 빈 상태 + 에러 혼합 뷰 (검색 결과 없음 등)
  struct EmptyWithErrorView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let onAction: (() -> Void)?
    
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Image(systemName: icon)
          .font(.system(size: 48))
          .foregroundColor(.githubTertiaryText)
        
        VStack(spacing: GitHubSpacing.sm) {
          Text(title)
            .font(.githubTitle3)
            .fontWeight(.semibold)
            .foregroundColor(.githubPrimaryText)
          
          Text(message)
            .font(.githubCallout)
            .foregroundColor(.githubSecondaryText)
            .multilineTextAlignment(.center)
        }
        
        if let actionTitle = actionTitle, let onAction = onAction {
          GitHubButton(
            actionTitle,
            style: .secondary
          ) {
            onAction()
          }
        }
      }
      .padding(.horizontal, GitHubSpacing.xl)
      .padding(.vertical, GitHubSpacing.xxl)
    }
  }
}

// MARK: - GitHubError Extension for UI
extension GitHubError {
  
  var iconName: String {
    switch self {
    // Request Errors
    case .invalidURL, .invalidQuery, .emptyQuery:
      return "exclamationmark.triangle"
    
    // Network Errors
    case .networkError, .noInternetConnection, .timeout, .serverUnavailable:
      return "wifi.slash"
    
    // API Errors
    case .unauthorized, .forbidden:
      return "lock"
    case .notFound:
      return "questionmark.folder"
    case .rateLimitExceeded:
      return "clock.badge.exclamationmark"
    case .validationFailed:
      return "checkmark.rectangle.stack.fill"
    case .internalServerError:
      return "server.rack"
    
    // Authentication Errors
    case .authenticationRequired, .authenticationFailed, .tokenExpired, .tokenInvalid:
      return "person.crop.circle.badge.exclamationmark"
    case .oauthCancelled:
      return "xmark.circle"
    case .oauthFailed:
      return "key.slash"
    
    // Response Errors
    case .noData, .invalidResponse:
      return "questionmark.square.dashed"
    case .decodingError:
      return "doc.plaintext"
    
    // Unknown Error
    case .unknown:
      return "exclamationmark.triangle"
    }
  }
  
  var iconColor: Color {
    switch self {
    // Request Errors
    case .invalidURL, .invalidQuery, .emptyQuery:
      return .githubWarning
    
    // Network Errors
    case .networkError, .noInternetConnection, .timeout, .serverUnavailable:
      return .githubSecondaryText
    
    // API Errors
    case .unauthorized, .forbidden:
      return .githubWarning
    case .notFound:
      return .githubSecondaryText
    case .rateLimitExceeded:
      return .githubWarning
    case .validationFailed:
      return .githubWarning
    case .internalServerError:
      return .githubRed
    
    // Authentication Errors
    case .authenticationRequired, .authenticationFailed, .tokenExpired, .tokenInvalid:
      return .githubWarning
    case .oauthCancelled:
      return .githubSecondaryText
    case .oauthFailed:
      return .githubWarning
    
    // Response Errors
    case .noData, .invalidResponse, .decodingError:
      return .githubSecondaryText
    
    // Unknown Error
    case .unknown:
      return .githubRed
    }
  }
  
  var title: String {
    switch self {
    // Request Errors
    case .invalidURL:
      return "잘못된 URL"
    case .invalidQuery:
      return "잘못된 검색어"
    case .emptyQuery:
      return "검색어 없음"
    
    // Network Errors
    case .networkError:
      return "네트워크 오류"
    case .noInternetConnection:
      return "인터넷 연결 없음"
    case .timeout:
      return "요청 시간 초과"
    case .serverUnavailable:
      return "서버 일시 중단"
    
    // API Errors
    case .unauthorized:
      return "인증 필요"
    case .forbidden:
      return "접근 권한 없음"
    case .notFound:
      return "찾을 수 없음"
    case .rateLimitExceeded:
      return "요청 한도 초과"
    case .validationFailed:
      return "입력값 오류"
    case .internalServerError:
      return "서버 오류"
    
    // Authentication Errors
    case .authenticationRequired:
      return "로그인 필요"
    case .authenticationFailed:
      return "인증 실패"
    case .tokenExpired:
      return "로그인 만료"
    case .tokenInvalid:
      return "인증 오류"
    case .oauthCancelled:
      return "로그인 취소"
    case .oauthFailed:
      return "로그인 실패"
    
    // Response Errors
    case .noData:
      return "데이터 없음"
    case .invalidResponse:
      return "응답 오류"
    case .decodingError:
      return "데이터 처리 오류"
    
    // Unknown Error
    case .unknown:
      return "알 수 없는 오류"
    }
  }
}


// MARK: - Color Extensions for Error States
extension Color {
  static let githubWarningBackground = Color.githubWarning.opacity(0.1)
}

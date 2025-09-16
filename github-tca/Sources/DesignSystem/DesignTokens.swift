import SwiftUI

// MARK: - 간격 시스템
struct GitHubSpacing {
  // 기본 간격 (4pt 기준)
  static let xxxs: CGFloat = 2    // 2pt
  static let xxs: CGFloat = 4     // 4pt
  static let xs: CGFloat = 8      // 8pt
  static let sm: CGFloat = 12     // 12pt
  static let md: CGFloat = 16     // 16pt
  static let lg: CGFloat = 20     // 20pt
  static let xl: CGFloat = 24     // 24pt
  static let xxl: CGFloat = 32    // 32pt
  static let xxxl: CGFloat = 40   // 40pt
  static let huge: CGFloat = 48   // 48pt
  
  // 특수 간격
  static let cardPadding: CGFloat = 16
  static let screenPadding: CGFloat = 20
  static let listItemSpacing: CGFloat = 12
  static let buttonPadding: CGFloat = 16
  static let iconSpacing: CGFloat = 8
}

// MARK: - 모서리 반지름
struct GitHubCornerRadius {
  static let small: CGFloat = 6
  static let medium: CGFloat = 8
  static let large: CGFloat = 12
  static let xlarge: CGFloat = 16
  static let card: CGFloat = 12
  static let button: CGFloat = 8
  static let avatar: CGFloat = 20
  static let circular: CGFloat = 999
}

// MARK: - 그림자
struct GitHubShadow {
  static let small = Shadow(
    color: Color.black.opacity(0.1),
    radius: 2,
    x: 0,
    y: 1
  )
  
  static let medium = Shadow(
    color: Color.black.opacity(0.15),
    radius: 4,
    x: 0,
    y: 2
  )
  
  static let large = Shadow(
    color: Color.black.opacity(0.2),
    radius: 8,
    x: 0,
    y: 4
  )
  
  static let card = Shadow(
    color: Color.black.opacity(0.25),
    radius: 6,
    x: 0,
    y: 3
  )
}

struct Shadow {
  let color: Color
  let radius: CGFloat
  let x: CGFloat
  let y: CGFloat
}

// MARK: - 아이콘 크기
struct GitHubIconSize {
  static let small: CGFloat = 16
  static let medium: CGFloat = 20
  static let large: CGFloat = 24
  static let xlarge: CGFloat = 32
  static let avatar: CGFloat = 40
  static let largeAvatar: CGFloat = 60
}

// MARK: - 애니메이션
struct GitHubAnimation {
  static let quick = Animation.easeInOut(duration: 0.2)
  static let standard = Animation.easeInOut(duration: 0.3)
  static let slow = Animation.easeInOut(duration: 0.5)
  static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
  static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
}

// MARK: - 투명도
struct GitHubOpacity {
  static let disabled: Double = 0.4
  static let secondary: Double = 0.6
  static let tertiary: Double = 0.8
  static let overlay: Double = 0.3
  static let backdrop: Double = 0.5
}

// MARK: - 버튼 크기
struct GitHubButtonSize {
  static let small = ButtonSize(height: 32, padding: 12)
  static let medium = ButtonSize(height: 40, padding: 16)
  static let large = ButtonSize(height: 48, padding: 20)
}

struct ButtonSize {
  let height: CGFloat
  let padding: CGFloat
}

import SwiftUI

extension Color {
    // MARK: - 시스템 기반 다이나믹 컬러
    static let githubBackground = Color(UIColor.systemBackground)
    static let githubCardBackground = Color(UIColor.secondarySystemBackground)
    static let githubSecondaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - 시스템 텍스트 컬러
    static let githubPrimaryText = Color(UIColor.label)
    static let githubSecondaryText = Color(UIColor.secondaryLabel)
    static let githubTertiaryText = Color(UIColor.tertiaryLabel)

  // MARK: - 액센트 컬러
  static let githubBlue = Color(red: 0.2, green: 0.533, blue: 1.0) // #3388FF
  static let githubGreen = Color(red: 0.133, green: 0.8, blue: 0.4) // #22CC66
  static let githubOrange = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933
  static let githubRed = Color(red: 1.0, green: 0.333, blue: 0.333) // #FF5555
  static let githubPurple = Color(red: 0.667, green: 0.4, blue: 1.0) // #AA66FF

    // MARK: - 시스템 구분선/테두리
    static let githubBorder = Color(UIColor.separator)
    static let githubSeparator = Color(UIColor.opaqueSeparator)

  // MARK: - 상태별 컬러
  static let githubSuccess = Color(red: 0.133, green: 0.8, blue: 0.4) // #22CC66
  static let githubWarning = Color(red: 1.0, green: 0.8, blue: 0.2) // #FFCC33
  static let githubError = Color(red: 1.0, green: 0.333, blue: 0.333) // #FF5555
  static let githubInfo = Color(red: 0.2, green: 0.733, blue: 1.0) // #33BBFF
}

// MARK: - 그라데이션
extension LinearGradient {
  static let githubCardGradient = LinearGradient(
    gradient: Gradient(colors: [
      Color.githubCardBackground,
      Color.githubSecondaryBackground
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let githubAccentGradient = LinearGradient(
    gradient: Gradient(colors: [
      Color.githubBlue,
      Color.githubPurple
    ]),
    startPoint: .leading,
    endPoint: .trailing
  )
}

import SwiftUI

// MARK: - 폰트 시스템
extension Font {
  // MARK: - 타이틀
  static let githubLargeTitle = Font.system(size: 34, weight: .bold, design: .default)
  static let githubTitle1 = Font.system(size: 28, weight: .bold, design: .default)
  static let githubTitle2 = Font.system(size: 22, weight: .bold, design: .default)
  static let githubTitle3 = Font.system(size: 20, weight: .semibold, design: .default)
  
  // MARK: - 헤드라인
  static let githubHeadline = Font.system(size: 17, weight: .semibold, design: .default)
  static let githubSubheadline = Font.system(size: 15, weight: .medium, design: .default)
  
  // MARK: - 바디
  static let githubBody = Font.system(size: 17, weight: .regular, design: .default)
  static let githubBodyEmphasized = Font.system(size: 17, weight: .medium, design: .default)
  static let githubCallout = Font.system(size: 16, weight: .regular, design: .default)
  
  // MARK: - 캡션
  static let githubFootnote = Font.system(size: 13, weight: .regular, design: .default)
  static let githubCaption = Font.system(size: 12, weight: .regular, design: .default)
  static let githubCaption2 = Font.system(size: 11, weight: .regular, design: .default)
  
  // MARK: - 특수 용도
  static let githubMonospaced = Font.system(size: 14, weight: .regular, design: .monospaced)
  static let githubRounded = Font.system(size: 16, weight: .medium, design: .rounded)
}

// MARK: - 텍스트 스타일 프리셋
struct GitHubTextStyle {
  let font: Font
  let color: Color
  let lineSpacing: CGFloat
  
  static let navigationTitle = GitHubTextStyle(
    font: .githubTitle2,
    color: .githubPrimaryText,
    lineSpacing: 2
  )
  
  static let sectionTitle = GitHubTextStyle(
    font: .githubHeadline,
    color: .githubPrimaryText,
    lineSpacing: 1
  )
  
  static let primaryText = GitHubTextStyle(
    font: .githubBody,
    color: .githubPrimaryText,
    lineSpacing: 2
  )
  
  static let secondaryText = GitHubTextStyle(
    font: .githubCallout,
    color: .githubSecondaryText,
    lineSpacing: 1
  )
  
  static let captionText = GitHubTextStyle(
    font: .githubFootnote,
    color: .githubTertiaryText,
    lineSpacing: 1
  )
  
  static let buttonText = GitHubTextStyle(
    font: .githubSubheadline,
    color: .githubPrimaryText,
    lineSpacing: 0
  )
  
  static let accentText = GitHubTextStyle(
    font: .githubBodyEmphasized,
    color: .githubBlue,
    lineSpacing: 1
  )
  
  static let linkText = GitHubTextStyle(
    font: .githubSubheadline,
    color: .githubAccent,
    lineSpacing: 0
  )
}

// MARK: - 간편한 텍스트 스타일 접근
extension Text {
  func primaryText() -> some View {
    self.githubStyle(.primaryText)
  }
  
  func secondaryText() -> some View {
    self.githubStyle(.secondaryText)
  }
  
  func captionText() -> some View {
    self.githubStyle(.captionText)
  }
  
  func linkText() -> some View {
    self.githubStyle(.linkText)
  }
}


extension View {
  func githubStyle(_ style: GitHubTextStyle) -> some View {
    self
      .font(style.font)
      .foregroundColor(style.color)
      .lineSpacing(style.lineSpacing)
  }
}

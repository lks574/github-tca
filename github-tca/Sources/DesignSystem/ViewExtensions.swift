import SwiftUI

// MARK: - View Extensions
extension View {
  // MARK: - GitHub 스타일 카드
  func githubCard(
    cornerRadius: CGFloat = GitHubCornerRadius.card,
    shadow: Shadow = GitHubShadow.card
  ) -> some View {
    self
      .background(Color.githubCardBackground)
      .cornerRadius(cornerRadius)
      .shadow(
        color: shadow.color,
        radius: shadow.radius,
        x: shadow.x,
        y: shadow.y
      )
  }

  // MARK: - GitHub 스타일 버튼
  func githubButton(
    style: GitHubButtonStyle = .primary,
    size: ButtonSize = GitHubButtonSize.medium
  ) -> some View {
    self
      .frame(height: size.height)
      .padding(.horizontal, size.padding)
      .background(style.backgroundColor)
      .foregroundColor(style.textColor)
      .cornerRadius(GitHubCornerRadius.button)
      .scaleEffect(1.0)
      .animation(GitHubAnimation.quick, value: true)
  }

  // MARK: - GitHub 스타일 리스트 아이템
  func githubListItem() -> some View {
    self
      .padding(.horizontal, GitHubSpacing.screenPadding)
      .padding(.vertical, GitHubSpacing.listItemSpacing)
      .background(Color.githubCardBackground)
      .cornerRadius(GitHubCornerRadius.medium)
  }

  // MARK: - 조건부 modifier
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }

  // MARK: - 햅틱 피드백
  func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
    self.onTapGesture {
      let impactFeedback = UIImpactFeedbackGenerator(style: style)
      impactFeedback.impactOccurred()
    }
  }

  // MARK: - GitHub 스타일 네비게이션
  func githubNavigationStyle() -> some View {
    self
      .navigationBarTitleDisplayMode(.large)
      .toolbarBackground(Color.githubBackground, for: .navigationBar)
//      .toolbarColorScheme(.dark, for: .navigationBar)
  }
  
  // MARK: - GitHub 버튼 스타일 적용
  func githubButtonStyle(_ style: GitHubButtonStyle) -> some View {
    self
      .font(.githubSubheadline)
      .foregroundColor(style.textColor)
      .padding(.horizontal, GitHubSpacing.md)
      .padding(.vertical, GitHubSpacing.sm)
      .background(style.backgroundColor)
      .cornerRadius(GitHubCornerRadius.button)
  }
}

// MARK: - 버튼 스타일
enum GitHubButtonStyle {
  case primary
  case secondary
  case accent
  case destructive
  case ghost

  var backgroundColor: Color {
    switch self {
    case .primary:
      return Color.githubCardBackground
    case .secondary:
      return Color.githubSecondaryBackground
    case .accent:
      return Color.githubBlue
    case .destructive:
      return Color.githubRed
    case .ghost:
      return Color.clear
    }
  }

  var textColor: Color {
    switch self {
    case .primary, .secondary:
      return Color.githubPrimaryText
    case .accent, .destructive:
      return Color.white
    case .ghost:
      return Color.githubBlue
    }
  }
}

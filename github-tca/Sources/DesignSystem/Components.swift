import SwiftUI

// MARK: - GitHub 스타일 카드 컴포넌트
struct GitHubCard<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    content
      .padding(GitHubSpacing.cardPadding)
      .githubCard()
  }
}

// MARK: - GitHub 스타일 버튼
struct GitHubButton: View {
  let title: String
  let icon: String?
  let style: GitHubButtonStyle
  let size: ButtonSize
  let action: () async -> Void
  
  @State private var isLoading = false
  
  init(
    _ title: String,
    icon: String? = nil,
    style: GitHubButtonStyle = .primary,
    size: ButtonSize = GitHubButtonSize.medium,
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.icon = icon
    self.style = style
    self.size = size
    self.action = action
  }
  
  var body: some View {
    Button {
      Task {
        isLoading = true
        await action()
        isLoading = false
      }
    } label: {
      HStack(spacing: GitHubSpacing.iconSpacing) {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: style.textColor))
            .scaleEffect(0.8)
        } else if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: GitHubIconSize.small, weight: .medium))
        }
        
        Text(title)
          .font(.githubSubheadline)
      }
    }
    .disabled(isLoading)
    .githubButton(style: style, size: size)
  }
}

// MARK: - GitHub 스타일 리스트 아이템
struct GitHubListItem: View {
  let icon: String
  let iconColor: Color
  let title: String
  let subtitle: String?
  let badge: String?
  let action: () async -> Void
  
  @State private var isLoading = false
  
  init(
    icon: String,
    iconColor: Color = .githubBlue,
    title: String,
    subtitle: String? = nil,
    badge: String? = nil,
    action: @escaping () async -> Void = {}
  ) {
    self.icon = icon
    self.iconColor = iconColor
    self.title = title
    self.subtitle = subtitle
    self.badge = badge
    self.action = action
  }
  
  var body: some View {
    Button {
      Task {
        isLoading = true
        await action()
        isLoading = false
      }
    } label: {
      HStack(spacing: GitHubSpacing.md) {
        // 아이콘
        RoundedRectangle(cornerRadius: GitHubCornerRadius.small)
          .fill(iconColor)
          .frame(width: GitHubIconSize.avatar, height: GitHubIconSize.avatar)
          .overlay(
            Image(systemName: icon)
              .font(.system(size: GitHubIconSize.medium, weight: .medium))
              .foregroundColor(.white)
          )
        
        VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
          Text(title)
            .githubStyle(.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          if let subtitle = subtitle {
            Text(subtitle)
              .githubStyle(.secondaryText)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        
        Spacer()
        
        HStack(spacing: GitHubSpacing.sm) {
          if let badge = badge {
            Text(badge)
              .font(.githubCaption)
              .foregroundColor(.githubPrimaryText)
              .padding(.horizontal, GitHubSpacing.xs)
              .padding(.vertical, GitHubSpacing.xxs)
              .background(Color.githubBlue)
              .cornerRadius(GitHubCornerRadius.small)
          }
          
          if isLoading {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .githubTertiaryText))
              .scaleEffect(0.8)
          } else {
            Image(systemName: "chevron.right")
              .font(.system(size: GitHubIconSize.small, weight: .medium))
              .foregroundColor(.githubTertiaryText)
          }
        }
      }
    }
    .disabled(isLoading)
    .buttonStyle(PlainButtonStyle())
    .githubListItem()
  }
}

// MARK: - GitHub 스타일 검색바
struct GitHubSearchBar: View {
  @Binding var text: String
  let placeholder: String
  
  var body: some View {
    HStack(spacing: GitHubSpacing.sm) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: GitHubIconSize.medium))
        .foregroundColor(.githubTertiaryText)
      
      TextField(placeholder, text: $text)
        .githubStyle(.primaryText)
    }
    .padding(GitHubSpacing.md)
    .background(Color.githubCardBackground)
    .cornerRadius(GitHubCornerRadius.medium)
  }
}

// MARK: - GitHub 스타일 섹션 헤더
struct GitHubSectionHeader: View {
  let title: String
  let action: (() -> Void)?
  
  init(_ title: String, action: (() -> Void)? = nil) {
    self.title = title
    self.action = action
  }
  
  var body: some View {
    HStack {
      Text(title)
        .githubStyle(.sectionTitle)
      
      Spacer()
      
      if let action = action {
        Button(action: action) {
          Image(systemName: "ellipsis")
            .font(.system(size: GitHubIconSize.medium, weight: .medium))
            .foregroundColor(.githubTertiaryText)
        }
      }
    }
    .padding(.horizontal, GitHubSpacing.screenPadding)
    .padding(.vertical, GitHubSpacing.sm)
  }
}

// MARK: - GitHub 스타일 뱃지
struct GitHubBadge: View {
  let text: String
  let color: Color
  
  init(_ text: String, color: Color = .githubBlue) {
    self.text = text
    self.color = color
  }
  
  var body: some View {
    Text(text)
      .font(.githubCaption)
      .foregroundColor(.white)
      .padding(.horizontal, GitHubSpacing.xs)
      .padding(.vertical, GitHubSpacing.xxs)
      .background(color)
      .cornerRadius(GitHubCornerRadius.small)
  }
}

// MARK: - 로딩 인디케이터
struct GitHubLoadingView: View {
  var body: some View {
    VStack(spacing: GitHubSpacing.lg) {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .githubBlue))
        .scaleEffect(1.2)
      
      Text("로딩 중...")
        .githubStyle(.secondaryText)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.githubBackground.opacity(0.8))
  }
}

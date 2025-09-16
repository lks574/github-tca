import SwiftUI
import ComposableArchitecture

enum NotificationsPage {
  struct RootView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Text("받은 편지함")
          .githubStyle(.navigationTitle)
        
        Spacer()
        
        VStack(spacing: GitHubSpacing.md) {
          Image(systemName: "bell.slash")
            .font(.system(size: 60))
            .foregroundColor(.githubTertiaryText)
          
          Text("새로운 알림이 없습니다")
            .githubStyle(.primaryText)
          
          Text("알림이 있으면 여기에 표시됩니다")
            .githubStyle(.secondaryText)
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.githubBackground)
      .navigationTitle("받은 편지함")
      .githubNavigationStyle()
    }
  }
}

import SwiftUI
import ComposableArchitecture

enum ProfilePage {
  struct RootView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Text("프로필")
          .githubStyle(.navigationTitle)
        
        Spacer()
        
        VStack(spacing: GitHubSpacing.md) {
          Image(systemName: "person.crop.circle")
            .font(.system(size: 60))
            .foregroundColor(.githubTertiaryText)
          
          Text("내 프로필")
            .githubStyle(.primaryText)
          
          Text("GitHub 계정 정보와 설정을 관리하세요")
            .githubStyle(.secondaryText)
            .multilineTextAlignment(.center)
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.githubBackground)
      .navigationTitle("프로필")
      .githubNavigationStyle()
    }
  }
}

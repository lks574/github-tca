import SwiftUI
import ComposableArchitecture

enum ExplorePage {
  struct RootView: View {
    var body: some View {
      VStack(spacing: GitHubSpacing.lg) {
        Text("탐색")
          .githubStyle(.navigationTitle)
        
        Spacer()
        
        VStack(spacing: GitHubSpacing.md) {
          Image(systemName: "safari")
            .font(.system(size: 60))
            .foregroundColor(.githubTertiaryText)
          
          Text("새로운 것을 발견해보세요")
            .githubStyle(.primaryText)
          
          Text("트렌딩 리포지토리와 개발자들을 찾아보세요")
            .githubStyle(.secondaryText)
            .multilineTextAlignment(.center)
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.githubBackground)
      .navigationTitle("탐색")
      .githubNavigationStyle()
    }
  }
}

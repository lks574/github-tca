import SwiftUI
import ComposableArchitecture

enum SettingsPage {
  struct RootView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
      ScrollView {
        LazyVStack(spacing: GitHubSpacing.lg) {
          ForEach(store.sections) { section in
            SettingsSectionView(
              section: section,
              onItemTapped: { store.send(.settingsItemTapped($0)) }
            )
          }
        }
        .padding(.horizontal, GitHubSpacing.screenPadding)
        .padding(.top, GitHubSpacing.md)
      }
      .background(Color.githubBackground)
      .navigationTitle("설정")
      .githubNavigationStyle()
      .onAppear {
        store.send(.onAppear)
      }
      .alert(store: store.scope(state: \.$alert, action: \.alert))
      .sheet(isPresented: $store.showingShareSheet) {
        ActivityView(activityItems: [store.shareText])
      }
    }
  }
  
  // MARK: - Settings Section View
  private struct SettingsSectionView: View {
    let section: SettingsModel.SettingsSection
    let onItemTapped: (SettingsModel.SettingsItem) -> Void
    
    var body: some View {
      VStack(spacing: GitHubSpacing.sm) {
        // 섹션 제목 (있는 경우에만)
        if let title = section.title {
          HStack {
            Text(title)
              .githubStyle(GitHubTextStyle.sectionTitle)
            Spacer()
          }
          .padding(.horizontal, GitHubSpacing.md)
        }
        
        // 설정 아이템들
        GitHubCard {
          VStack(spacing: 0) {
            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
              SettingsItemView(
                item: item,
                isLast: index == section.items.count - 1,
                onTapped: { onItemTapped(item) }
              )
              
              if index < section.items.count - 1 {
                Divider()
                  .background(Color.githubBorder)
                  .padding(.horizontal, GitHubSpacing.md)
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: - Settings Item View
  private struct SettingsItemView: View {
    let item: SettingsModel.SettingsItem
    let isLast: Bool
    let onTapped: () -> Void
    
    var body: some View {
      Button(action: onTapped) {
        HStack(spacing: GitHubSpacing.md) {
          // 아이콘 (있는 경우)
          if let icon = item.icon {
            HStack {
              Image(systemName: icon)
                .font(.system(size: GitHubIconSize.medium))
                .foregroundColor(item.iconColor ?? .githubAccent)
                .frame(width: GitHubIconSize.medium, height: GitHubIconSize.medium)
            }
            .frame(width: 24, height: 24)
          }
          
          // 타이틀과 서브타이틀
          VStack(alignment: .leading, spacing: GitHubSpacing.xxs) {
            HStack {
              Text(item.title)
                .githubStyle(GitHubTextStyle.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              // 값 표시 (있는 경우)
              if let value = item.value {
                Text(value)
                  .githubStyle(GitHubTextStyle.captionText)
              }
            }
            
            // 서브타이틀 (있는 경우)
            if let subtitle = item.subtitle {
              Text(subtitle)
                .githubStyle(GitHubTextStyle.captionText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          
          // 액세서리 뷰
          AccessoryView(for: item.type)
        }
        .padding(.horizontal, GitHubSpacing.md)
        .padding(.vertical, GitHubSpacing.md)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      .disabled(item.type == .info)
    }
  }
  
  // MARK: - Accessory View
  private struct AccessoryView: View {
    let type: SettingsModel.SettingsItemType
    
    init(for type: SettingsModel.SettingsItemType) {
      self.type = type
    }
    
    var body: some View {
      switch type {
      case .navigation, .action:
        Image(systemName: "chevron.right")
          .font(.system(size: GitHubIconSize.small, weight: .medium))
          .foregroundColor(.githubTertiaryText)
        
      case .toggle:
        Toggle("", isOn: .constant(false))
          .labelsHidden()
        
      case .value, .info:
        EmptyView()
      }
    }
  }
}

// MARK: - Activity View for Sharing
struct ActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: nil
    )
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    // No updates needed
  }
}

// MARK: - Preview
#if DEBUG
struct SettingsPage_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsPage.RootView(
        store: Store(initialState: SettingsReducer.State()) {
          SettingsReducer()
        }
      )
    }
    .previewDisplayName("Settings")
  }
}
#endif

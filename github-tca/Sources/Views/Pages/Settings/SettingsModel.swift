import Foundation
import SwiftUI

enum SettingsModel {
  
  // MARK: - Settings Section
  struct SettingsSection: Equatable, Identifiable {
    let id = UUID()
    let title: String?
    let items: [SettingsItem]
    
    init(title: String? = nil, items: [SettingsItem]) {
      self.title = title
      self.items = items
    }
  }
  
  // MARK: - Settings Item
  struct SettingsItem: Equatable, Identifiable {
    let id = UUID()
    let type: SettingsItemType
    let title: String
    let subtitle: String?
    let value: String?
    let icon: String?
    let iconColor: Color?
    let action: SettingsAction
    
    init(
      type: SettingsItemType,
      title: String,
      subtitle: String? = nil,
      value: String? = nil,
      icon: String? = nil,
      iconColor: Color? = nil,
      action: SettingsAction = .none
    ) {
      self.type = type
      self.title = title
      self.subtitle = subtitle
      self.value = value
      self.icon = icon
      self.iconColor = iconColor
      self.action = action
    }
  }
  
  // MARK: - Settings Item Type
  enum SettingsItemType: Equatable {
    case navigation  // 화살표가 있는 네비게이션 아이템
    case toggle      // 토글 스위치
    case value       // 값을 표시하는 아이템
    case action      // 액션 버튼
    case info        // 정보 표시
  }
  
  // MARK: - Settings Action
  enum SettingsAction: Equatable {
    case none
    case navigation(SettingsDestination)
    case toggle(Bool)
    case external(URL)
    case share(String)
    case feedback
    case logout
  }
  
  // MARK: - Settings Destination
  enum SettingsDestination: Equatable {
    case appearance
    case language
    case notifications
    case codeOptions
    case webLinks
    case about
    case help
  }
  
  // MARK: - User Settings
  struct UserSettings: Equatable {
    var appearance: AppearanceMode = .auto
    var language: Language = .korean
    var notificationsEnabled: Bool = true
    var codeHighlighting: Bool = true
    var webLinksEnabled: Bool = true
  }
  
  // MARK: - Appearance Mode
  enum AppearanceMode: String, CaseIterable, Equatable {
    case light = "라이트"
    case dark = "다크"
    case auto = "자동"
    
    var systemValue: ColorScheme? {
      switch self {
      case .light: return .light
      case .dark: return .dark
      case .auto: return nil
      }
    }
  }
  
  // MARK: - Language
  enum Language: String, CaseIterable, Equatable {
    case korean = "한국어"
    case english = "English"
    case japanese = "日本語"
    
    var code: String {
      switch self {
      case .korean: return "ko"
      case .english: return "en"
      case .japanese: return "ja"
      }
    }
  }
}

// MARK: - Default Settings Data
extension [SettingsModel.SettingsSection] {
  static let `default`: Self = [
    // 앱 설정 섹션
    SettingsModel.SettingsSection(items: [
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "모양",
        value: "자동",
        action: .navigation(.appearance)
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "앱 아이콘",
        value: "기본값",
        action: .navigation(.appearance)
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "앱 언어",
        value: "한국어",
        action: .navigation(.language)
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "알림",
        value: "설정 필요",
        action: .navigation(.notifications)
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "코드 옵션",
        action: .navigation(.codeOptions)
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "외부 링크",
        action: .navigation(.webLinks)
      )
    ]),
    
    // 서비스 섹션
    SettingsModel.SettingsSection(items: [
      SettingsModel.SettingsItem(
        type: .info,
        title: "Copilot",
        subtitle: "새로 만들기",
        value: "Copilot Free",
        icon: "brain.head.profile",
        iconColor: .githubBlue
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "GitHub Pro",
        action: .external(URL(string: "https://github.com/pricing")!)
      )
    ]),
    
    // 지원 섹션
    SettingsModel.SettingsSection(items: [
      SettingsModel.SettingsItem(
        type: .action,
        title: "피드백 공유",
        icon: "square.and.arrow.up",
        iconColor: .githubSecondaryText,
        action: .feedback
      ),
      SettingsModel.SettingsItem(
        type: .navigation,
        title: "도움말 보기",
        action: .navigation(.help)
      )
    ])
  ]
}

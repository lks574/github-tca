import ComposableArchitecture
import SwiftUI

@Reducer
struct SettingsReducer {
  
  @ObservableState
  struct State: Equatable {
    var sections: [SettingsModel.SettingsSection] = [SettingsModel.SettingsSection].default
    var userSettings: SettingsModel.UserSettings = SettingsModel.UserSettings()
    
    // Alert states
    @Presents var alert: AlertState<Action.Alert>?
    
    // Sheet states
    var showingShareSheet = false
    var shareText = ""
  }
  
  enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    
    // Settings Actions
    case settingsItemTapped(SettingsModel.SettingsItem)
    case appearanceModeChanged(SettingsModel.AppearanceMode)
    case languageChanged(SettingsModel.Language)
    case notificationToggled(Bool)
    case codeHighlightingToggled(Bool)
    case webLinksToggled(Bool)
    
    // Navigation Actions
    case navigateToAppearance
    case navigateToLanguage
    case navigateToNotifications
    case navigateToCodeOptions
    case navigateToWebLinks
    case navigateToAbout
    case navigateToHelp
    
    // External Actions
    case openExternalURL(URL)
    case shareFeedback
    case showAlert(String)
    
    // Alert Actions
    case alert(PresentationAction<Alert>)
    
    enum Alert: Equatable {
      case confirmLogout
    }
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        // 사용자 설정에 따라 섹션 업데이트
        state.sections = updateSectionsWithUserSettings(state.userSettings)
        return .none
        
      case let .settingsItemTapped(item):
        return handleSettingsItemAction(item.action, state: &state)
        
      case let .appearanceModeChanged(mode):
        state.userSettings.appearance = mode
        state.sections = updateSectionsWithUserSettings(state.userSettings)
        return .none
        
      case let .languageChanged(language):
        state.userSettings.language = language
        state.sections = updateSectionsWithUserSettings(state.userSettings)
        return .none
        
      case let .notificationToggled(enabled):
        state.userSettings.notificationsEnabled = enabled
        state.sections = updateSectionsWithUserSettings(state.userSettings)
        return .none
        
      case let .codeHighlightingToggled(enabled):
        state.userSettings.codeHighlighting = enabled
        return .none
        
      case let .webLinksToggled(enabled):
        state.userSettings.webLinksEnabled = enabled
        return .none
        
      // Navigation Actions
      case .navigateToAppearance,
           .navigateToLanguage,
           .navigateToNotifications,
           .navigateToCodeOptions,
           .navigateToWebLinks,
           .navigateToAbout,
           .navigateToHelp:
        // 네비게이션은 상위에서 처리
        return .none
        
      case let .openExternalURL(url):
        return .run { _ in
          await UIApplication.shared.open(url)
        }
        
      case .shareFeedback:
        state.shareText = """
        GitHub TCA 앱 피드백
        
        앱 버전: 1.0.0
        iOS 버전: \(UIDevice.current.systemVersion)
        기기: \(UIDevice.current.model)
        
        여기에 피드백을 작성해주세요:
        """
        state.showingShareSheet = true
        return .none
        
      case let .showAlert(message):
        state.alert = AlertState {
          TextState("알림")
        } actions: {
          ButtonState(role: .cancel) {
            TextState("확인")
          }
        } message: {
          TextState(message)
        }
        return .none
        
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
  
  // MARK: - Private Methods
  
  private func handleSettingsItemAction(
    _ action: SettingsModel.SettingsAction,
    state: inout State
  ) -> Effect<Action> {
    switch action {
    case .none:
      return .none
      
    case let .navigation(destination):
      switch destination {
      case .appearance:
        return .send(.navigateToAppearance)
      case .language:
        return .send(.navigateToLanguage)
      case .notifications:
        return .send(.navigateToNotifications)
      case .codeOptions:
        return .send(.navigateToCodeOptions)
      case .webLinks:
        return .send(.navigateToWebLinks)
      case .about:
        return .send(.navigateToAbout)
      case .help:
        return .send(.navigateToHelp)
      }
      
    case let .toggle(isOn):
      return .send(.showAlert("토글 기능: \(isOn ? "켜짐" : "꺼짐")"))
      
    case let .external(url):
      return .send(.openExternalURL(url))
      
    case let .share(text):
      state.shareText = text
      state.showingShareSheet = true
      return .none
      
    case .feedback:
      return .send(.shareFeedback)
      
    case .logout:
      state.alert = AlertState {
        TextState("로그아웃")
      } actions: {
        ButtonState(role: .destructive, action: .confirmLogout) {
          TextState("로그아웃")
        }
        ButtonState(role: .cancel) {
          TextState("취소")
        }
      } message: {
        TextState("정말 로그아웃하시겠습니까?")
      }
      return .none
    }
  }
  
  private func updateSectionsWithUserSettings(
    _ userSettings: SettingsModel.UserSettings
  ) -> [SettingsModel.SettingsSection] {
    var sections = [SettingsModel.SettingsSection].default
    
    // 첫 번째 섹션의 아이템들 업데이트
    if !sections.isEmpty {
      var updatedItems = sections[0].items
      
      // 모양 설정 업데이트
      if let appearanceIndex = updatedItems.firstIndex(where: { $0.title == "모양" }) {
        updatedItems[appearanceIndex] = SettingsModel.SettingsItem(
          type: .navigation,
          title: "모양",
          value: userSettings.appearance.rawValue,
          action: .navigation(.appearance)
        )
      }
      
      // 언어 설정 업데이트
      if let languageIndex = updatedItems.firstIndex(where: { $0.title == "앱 언어" }) {
        updatedItems[languageIndex] = SettingsModel.SettingsItem(
          type: .navigation,
          title: "앱 언어",
          value: userSettings.language.rawValue,
          action: .navigation(.language)
        )
      }
      
      // 알림 설정 업데이트
      if let notificationIndex = updatedItems.firstIndex(where: { $0.title == "알림" }) {
        updatedItems[notificationIndex] = SettingsModel.SettingsItem(
          type: .navigation,
          title: "알림",
          value: userSettings.notificationsEnabled ? "켜짐" : "꺼짐",
          action: .navigation(.notifications)
        )
      }
      
      sections[0] = SettingsModel.SettingsSection(
        title: sections[0].title,
        items: updatedItems
      )
    }
    
    return sections
  }
}

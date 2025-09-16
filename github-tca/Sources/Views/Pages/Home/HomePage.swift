import Foundation
import ComposableArchitecture
import SwiftUI

enum HomePage {
  struct RootView: View {
    @Bindable var store: StoreOf<HomeReducer>

    var body: some View {
      VStack(spacing: 0) {
      }
    }
  }
}

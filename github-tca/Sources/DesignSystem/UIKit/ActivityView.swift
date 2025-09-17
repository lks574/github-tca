import SwiftUI

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

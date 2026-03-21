import SwiftUI

@main
struct CleanSignalApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerView()
                .preferredColorScheme(.dark)
        }
    }
}

import SwiftUI

@main
struct Rugby_MomentumApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LaunchScaffold {
                MainTabView()
            }
            .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    nonisolated func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        if MainActor.assumeIsolated({ LayoutDirector.shared.landscapeEnabled }) {
            return .all
        }
        return .portrait
    }
}

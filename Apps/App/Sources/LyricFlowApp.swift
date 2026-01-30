import SwiftUI

@main
struct LyricFlowApp: App {
    @UIApplicationDelegateAdaptor(CarPlaySceneDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

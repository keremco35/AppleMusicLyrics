import Foundation
import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, UIApplicationDelegate {
    var interfaceController: CPInterfaceController?
    private var listTemplate: CPListTemplate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        self.interfaceController = interfaceController

        let item = CPListItem(text: "LyricFlow", detailText: "Waiting for track...")
        let section = CPListSection(items: [item])
        let template = CPListTemplate(title: "Now Playing", sections: [section])
        self.listTemplate = template

        interfaceController.setRootTemplate(template, animated: true, completion: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleLyricsUpdate(_:)), name: .init("LyricsUpdate"), object: nil)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow) {
        self.interfaceController = nil
        self.listTemplate = nil
    }

    @objc private func handleLyricsUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let line = userInfo["line"] as? String,
              let next = userInfo["next"] as? String else { return }

        let item = CPListItem(text: line, detailText: next)
        item.setImage(UIImage(systemName: "music.note"))

        let section = CPListSection(items: [item])
        listTemplate?.updateSections([section])
    }
}

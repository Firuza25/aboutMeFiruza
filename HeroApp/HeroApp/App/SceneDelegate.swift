

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Setup router and service
        let router = HeroRouter()
        let heroService = HeroServiceImpl(session: .shared)
        let viewModel = HeroListViewModel(service: heroService, router: router)

        // Create main list view controller
        let listView = HeroListView(viewModel: viewModel)
        let listViewController = UIHostingController(rootView: listView)
        
        // Setup navigation controller
        let rootViewController = UINavigationController(rootViewController: listViewController)
        
        // Set the appearance of the navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Connect router to navigation controller
        router.rootViewController = rootViewController

        // Set rootViewController and make window visible
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    // Other scene delegate methods remain unchanged
}

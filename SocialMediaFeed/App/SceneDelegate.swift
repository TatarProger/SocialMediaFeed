//
//  SceneDelegate.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

// App/SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let feedVC = DIContainer.shared.makeFeedViewController()
        let nav = UINavigationController(rootViewController: feedVC)

        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
    }
}



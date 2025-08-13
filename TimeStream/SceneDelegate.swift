//
//  SceneDelegate.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit
import FirebaseAuth
import Stripe
import Adyen

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appManager: AppNavigationManager!
    var deepLinkManager: DeepLinkingManager!
    
    // MARK: Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        appManager = AppNavigationManager()
        deepLinkManager = DeepLinkingManager()
        deepLinkManager.delegate = appManager
        
        appManager.start()
        
        for userActivity in connectionOptions.userActivities {
            if let url = userActivity.webpageURL {
                deepLinkManager.handleLink(link: url)
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let url = urlContext.url
            Auth.auth().canHandle(url)
            StripeAPI.handleURLCallback(with: url)
            RedirectComponent.applicationDidOpen(from: url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            return
        }
        
        deepLinkManager.handleLink(link: url)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}


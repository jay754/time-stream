//
//  AppFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import UIKit


class AppNavigationManager {
    // Flows
    let main: MainFlowManager!
    let onboarding: OnboardingFlowManager!
    let authenticationFlow: AuthenticationFlowManager!
    
    let deepLinking: DeepLinkingFlowManager!
    
    // Navigation Controllers
    let navigationController = UINavigationController()
    let overlayNavController = UINavigationController()

    
    // MARK: Lifecycle
    
    init() {
        main = MainFlowManager(navigationController: navigationController)
        onboarding = OnboardingFlowManager(navigationController: navigationController)
        deepLinking = DeepLinkingFlowManager(navigationController: overlayNavController)
        authenticationFlow = AuthenticationFlowManager(navigationController: navigationController, overlay: false)
       
        main.delegate = self
        onboarding.delegate = self
        deepLinking.delegate = self
        authenticationFlow.delegate = self
        
        changeRootVC(root: navigationController)
    }
    
    // MARK: Public methods
    
    func start() {
//        main.startFlow()
        onboarding.startFlow()
    }
    
    // MARK: Protected methods
    
    private func changeRootVC(root: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate else {
            
            return
        }
        
        delegate.window = UIWindow(windowScene: scene)
        delegate.window?.rootViewController = root
        delegate.window?.makeKeyAndVisible()
    }

}

extension AppNavigationManager: BaseFlowDelegate {
    
    func startMain() {
        main.startFlow()
    }
    
    func startAuthentication() {
        authenticationFlow.startFlow()
    }
    
    func flowDidStart(flow: BaseFlowManager) {
        
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        if flow === onboarding {
            if Context.current.authenticated, Context.current.user != nil {
                startMain()
                
            } else {
                startAuthentication()
            }
        }
        
        if flow === authenticationFlow {
            startMain()
        }
        
        if flow === deepLinking {
            overlayNavController.dismiss(animated: true)
        }
        
        if flow === main {
            onboarding.startFlow()
        }
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
        
    }

}


extension AppNavigationManager: DeepLinkingManagerDelegate {
    func deepLinkingGoToUser(manager: DeepLinkingManager, user: User) {
        deepLinking.showUser(user: user)
        presentOverlay()
    }
    
    func deepLinkingGoToVideo(manager: DeepLinkingManager, video: Video) {
        deepLinking.showVideoDetails(video: video)
        presentOverlay()
    }
    
    private func presentOverlay() {
        overlayNavController.modalPresentationStyle = .overFullScreen
        navigationController.getTopViewController().present(overlayNavController, animated: true, completion: nil)
    }
}

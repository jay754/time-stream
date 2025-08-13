//
//  DeepLinkingManager.swift
//  TimeStream
//
//  Created by appssemble on 25.10.2021.
//

import UIKit

class DeepLinkingFlowManager: BaseFlowManager {
    
    private let miscFlowManager: MiscFlowManager
    private let profileFlow: ProfileFlowManager
    
    // Overwritten
    
    override init(navigationController: UINavigationController) {
        miscFlowManager = MiscFlowManager(navigationController: navigationController)
        profileFlow = ProfileFlowManager(navigationController: navigationController)
        
        super.init(navigationController: navigationController)
        
        miscFlowManager.delegate = self
        profileFlow.delegate = self
    }
    
    override func backButtonPressed(from viewController: UIViewController) {
        if navigationController.viewControllers.count == 1 {
            delegate?.flowDidFinish(flow: self)
        }
        
        super.backButtonPressed(from: viewController)
    }
    
    // MARK: Delegate
    
    func showVideoDetails(video: Video) {
        navigationController.viewControllers = []
        miscFlowManager.startVideoDetails(video: video)
    }
    
    func showUser(user: User) {
        navigationController.viewControllers = []
        profileFlow.startOtherUserFlow(user: user)
    }
    
    // MARK: Private methods
}

extension DeepLinkingFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        delegate?.flowDidStart(flow: self)
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        delegate?.flowDidFinish(flow: self)
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
        delegate?.flowDidCancel(flow: self)
    }
}

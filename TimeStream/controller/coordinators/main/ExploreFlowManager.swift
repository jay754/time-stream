//
//  ExploreFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import Foundation
import UIKit

class ExploreFlowManager: BaseFlowManager {

    private enum Screen: String {
        case explore
        case category
        case categories
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Explore
        }
    }
    
    private let authNavController = UINavigationController()
    private let miscFlowManger: MiscFlowManager!
    private let profileFlow: ProfileFlowManager!
    private let authenticationFlow: AuthenticationFlowManager!
    
    override init(navigationController: UINavigationController) {
        miscFlowManger = MiscFlowManager(navigationController: navigationController)
        profileFlow = ProfileFlowManager(navigationController: navigationController)
        authenticationFlow = AuthenticationFlowManager(navigationController: authNavController, overlay: true)
        
        super.init(navigationController: navigationController)
        
        authenticationFlow.delegate = self
    }

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true
        
        shouldReplaceNavigationStack = true
        goToViewControllerWithIdentifier(identifier: Screen.explore.rawValue)
    }
    
    func startFlow(category: Category) {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true
        
        shouldReplaceNavigationStack = true
        goToViewControllerWithIdentifier(identifier: Screen.explore.rawValue, setupClosure: { vc in
            if let vc = vc as? ExploreViewController {
                vc.selectedCategory = category
            }
        })
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? ExploreViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ExploreCategoryDetailsViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ExploreCategoriesOfInterestViewController {
            vc.flowDelegate = self
        }
    }
    
    
    // MARK: Private methods
}

extension ExploreFlowManager: ExploreFlowDelegate {
    func exploreGoToCategory(vc: ExploreViewController, category: Category) {
        goToViewControllerWithIdentifier(identifier: Screen.category.rawValue) { vc in
            if let vc = vc as? ExploreCategoryDetailsViewController {
                vc.category = category
            }
        }
    }
    
    func exploreGoToUser(vc: ExploreViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
    
    func exploreGoToCategoriesSelection(vc: ExploreViewController) {
        goToViewControllerWithIdentifier(identifier: Screen.categories.rawValue)
    }
    
    func exploreGoToVideo(vc: ExploreViewController, video: Video) {
        miscFlowManger.startVideoDetails(video: video)
    }
    
    func exploreHandleLoginAndDoAction(vc: ExploreViewController, completion: @escaping SimpleAuthClosure) {
        authenticationFlow.authenticateIfNeededAndDoAction(from: navigationController, action: completion)
    }
    
}

extension ExploreFlowManager: ExploreCategoryDetailsFlowDelegate {

    func exploreCategoryGoToVideo(vc: ExploreCategoryDetailsViewController, video: Video) {
        miscFlowManger.startVideoDetails(video: video)
    }
    
}

extension ExploreFlowManager: ExploreCategoriesOfInterestFlowDelegate {

}

extension ExploreFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        
    }
    
    func flowDidFinish(flow: BaseFlowManager) {        
        if flow === authenticationFlow {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
    
    func flowDidCancel(flow: BaseFlowManager) {

    }
}

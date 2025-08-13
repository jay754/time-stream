//
//  HomeFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import Foundation
import UIKit

protocol HomeFlowActionsDelegate: AnyObject {
    func homeFlowGoToExploreCategory(flow: HomeFlowManager, category: Category)
}

class HomeFlowManager: BaseFlowManager {
    
    weak var actionsDelegate: HomeFlowActionsDelegate?

    private enum Screen: String {
        case home
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Home
        }
    }
    
    private let miscFlowManger: MiscFlowManager
    private let profileFlow: ProfileFlowManager
    
    private lazy var newFlow: NewFlowManager = {
        let newFlow = NewFlowManager(navigationController: navigationController)
        return newFlow
    }()
    
    override init(navigationController: UINavigationController) {
        miscFlowManger = MiscFlowManager(navigationController: navigationController)
        profileFlow = ProfileFlowManager(navigationController: navigationController)
        
        super.init(navigationController: navigationController)
    }
    
    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToViewControllerWithIdentifier(identifier: Screen.home.rawValue)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? HomeViewController {
            vc.flowDelegate = self
        }
    }
    
    
    // MARK: Private methods
}

extension HomeFlowManager: HomeFlowDelegate {
  
    func homeViewGoToVideo(vc: HomeViewController, video: Video) {
        miscFlowManger.startVideoDetails(video: video)
    }
    
    func homeViewGoToExploreCategory(vc: HomeViewController, category: Category) {
        actionsDelegate?.homeFlowGoToExploreCategory(flow: self, category: category)
    }
    
    func homeViewGoToRequestVideo(vc: HomeViewController, user: User) {
        newFlow.startNewRequest(vc: vc, forUser: user)
    }
    
    func homeViewGoToUser(vc: HomeViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
}

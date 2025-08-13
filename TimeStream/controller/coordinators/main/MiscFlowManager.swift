//
//  MiscFlowManager.swift
//  TimeStream
//
//  Created on 11.08.2021.
//

import Foundation
import UIKit

class MiscFlowManager: BaseFlowManager {

    private enum Screen: String {
        case webPage
        case videoDetails
        case pickCategory
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Misc
        }
    }
    
    private lazy var profileFlow: ProfileFlowManager = {
        let profileFlow = ProfileFlowManager(navigationController: navigationController)
        return profileFlow
    }()
    
    private let authFlowNav = UINavigationController()
    private lazy var authenticationFlow: AuthenticationFlowManager = {
        let flow = AuthenticationFlowManager(navigationController: authFlowNav, overlay: true)
        flow.delegate = self
        return flow
    }()
    
    private lazy var newFlow: NewFlowManager = {
        let newFlow = NewFlowManager(navigationController: navigationController)
        return newFlow
    }()

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToViewControllerWithIdentifier(identifier: Screen.webPage.rawValue)
    }
    
    override func backButtonPressed(from viewController: UIViewController) {
        if navigationController.viewControllers.count == 1 {
            delegate?.flowDidFinish(flow: self)
        }
        
        super.backButtonPressed(from: viewController)
    }
    
    func startVideoDetails(video: Video) {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToVideo(video: video)
    }
    
    func startWebPage(title: String, url: URL) {
        navigationController.navigationBar.isHidden = false
        
        goToViewControllerWithIdentifier(identifier: Screen.webPage.rawValue) { (vc) in
            if let vc = vc as? WebPageViewController {
                vc.name = title
                vc.url = url
            }
        }
    }
    
    func startCategoryPicker(selectedCategory: Category?, delegate: CategoryPickerActionDelegate, otherTitle: String? = nil) {
        navigationController.navigationBar.isHidden = false
        
        goToViewControllerWithIdentifier(identifier: Screen.pickCategory.rawValue) { (vc) in
            if let vc = vc as? CategoryPickerViewController {
                vc.selectedCategory = selectedCategory
                vc.actionsDelegate = delegate
                vc.otherTitle = otherTitle
            }
        }
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? WebPageViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? VideoDetailsViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? CategoryPickerViewController {
            vc.flowDelegate = self
        }
    }
    
    
    // MARK: Private methods
    
    private func goToVideo(video: Video) {
        goToViewControllerWithIdentifier(identifier: Screen.videoDetails.rawValue){ (vc) in
            if let vc = vc as? VideoDetailsViewController {
                vc.video = video
            }
        }
    }
}

extension MiscFlowManager: WebPageViewControllerFlowDelegate {
    
}

extension MiscFlowManager: VideoDetailsFlowDelegate {
    func videoDetailsGoToRequestVideo(vc: VideoDetailsViewController, user: User) {
        newFlow.startNewRequest(vc: vc, forUser: user)
    }
    
    func videoDetailsAuthenticateAndDo(vc: VideoDetailsViewController, completion: @escaping SimpleAuthClosure) {
        authenticationFlow.authenticateIfNeededAndDoAction(from: navigationController, action: completion)
    }
    
    func videoDetailsGoToUser(vc: VideoDetailsViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
    
    func videoDetailsGoToVideo(vc: VideoDetailsViewController, video: Video) {
        goToVideo(video: video)
    }
}

extension MiscFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        // Do nothing
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        if flow === authenticationFlow {
            authFlowNav.dismiss(animated: true, completion: nil)
        }
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
       // Do nothing
    }
}

extension MiscFlowManager: CategoryPickerFlowDelegate {
    
}

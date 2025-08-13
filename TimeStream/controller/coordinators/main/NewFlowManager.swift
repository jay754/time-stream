//
//  NewFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import UIKit

class NewFlowManager: BaseFlowManager {

    private enum Screen: String {
        case new
        case preview
        case edit
        case description
        case responseOverview
        case requestOverview
        case newResponse
        case newRequest
    }
    
    override var storyboardName: StoryboardName {
        get {
            .New
        }
    }
    
    private var requestStartedFromVC: UIViewController?
    private var responseStartedFromVC: UIViewController?
    
    private let miscFlow: MiscFlowManager!
    
    // MARK: Overwritten
    
    override init(navigationController: UINavigationController) {
        miscFlow = MiscFlowManager(navigationController: navigationController)
       
        super.init(navigationController: navigationController)
    }

    override func startFlow() {
        super.startFlow()
        
        shouldReplaceNavigationStack = true
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToViewControllerWithIdentifier(identifier: Screen.new.rawValue)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? NewViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? PreviewRecordingViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? EditVideoViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? VideoDescriptionViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? NewResponseViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ResponseOverviewViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? NewRequestViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? RequestOverviewViewController {
            vc.flowDelegate = self
        }
    }
    
    override func backButtonPressed(from viewController: UIViewController) {
        if navigationController.viewControllers.count == 1 {
            delegate?.flowDidCancel(flow: self)
        } else {
            super.backButtonPressed(from: viewController)
        }
    }
    
    // MARK: Methods
    
    func startNewRequest(vc: UIViewController, forUser: User) {
        requestStartedFromVC = vc
        
        goToViewControllerWithIdentifier(identifier: Screen.newRequest.rawValue) { (vc) in
            if let vc = vc as? NewRequestViewController {
                vc.user = forUser
            }
        }
    }
    
    func startNewResponse(message: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.newResponse.rawValue) { (vc) in
            if let vc = vc as? NewResponseViewController {
                vc.message = message
                vc.conversation = conversation
            }
        }
    }
    
    // MARK: Private methods
}

extension NewFlowManager: NewFlowDelegate {
    func newFlowGoToPreview(vc: NewViewController, url: URL) {
        goToViewControllerWithIdentifier(identifier: Screen.preview.rawValue) { (vc) in
            if let vc = vc as? PreviewRecordingViewController {
                vc.url = url
            }
        }
    }
}

extension NewFlowManager: PreviewRecordingFlowDelegate {
    func previewGoAddDetails(vc: PreviewRecordingViewController, url: URL) {
        goToViewControllerWithIdentifier(identifier: Screen.description.rawValue) { (vc) in
            if let vc = vc as? VideoDescriptionViewController {
                vc.videoURL = url
            }
        }
    }

    func previewGoToEditVideo(vc: PreviewRecordingViewController, url: URL, editDelegate: EditVideoViewControllerTrimDelegate?) {
        goToViewControllerWithIdentifier(identifier: Screen.edit.rawValue) { (vc) in
            if let vc = vc as? EditVideoViewController {
                vc.url = url
                vc.trimDelegate = editDelegate
            }
        }
    }
}

extension NewFlowManager: EditVideoViewControllerFlowDelegate {

}

extension NewFlowManager: VideoDescriptionFlowDelegate {
    
    func videoDescriptionPickCateogry(vc: VideoDescriptionViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate) {
        miscFlow.startCategoryPicker(selectedCategory: selectedCategory, delegate: delegate)
    }
    
    func videoWasUploaded(vc: VideoDescriptionViewController) {
        delegate?.flowDidFinish(flow: self)
    }
}

extension NewFlowManager: NewResponseViewControllerFlowDelegate {
    func newResponseGoToPreview(vc: NewResponseViewController, url: URL, message: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.responseOverview.rawValue) { (vc) in
            if let vc = vc as? ResponseOverviewViewController {
                vc.url = url
                vc.message = message
                vc.conversation = conversation
            }
        }
    }
}

extension NewFlowManager: ResponseOverviewViewControllerFlowDelegate {
    func responsePreviewGoToEditVideo(vc: ResponseOverviewViewController, url: URL, maxDuration: Int, editDelegate: EditVideoViewControllerTrimDelegate?) {
        
        goToViewControllerWithIdentifier(identifier: Screen.edit.rawValue) { (vc) in
            if let vc = vc as? EditVideoViewController {
                vc.url = url
                vc.trimMaxDuration = maxDuration
                vc.trimDelegate = editDelegate
            }
        }
    }
    
    func responsePreviewHasSentResponse(vc: ResponseOverviewViewController) {
        delegate?.flowDidFinish(flow: self)
    }
}


extension NewFlowManager: NewRequestViewControllerFlowDelegate {
    func newRequestGoToPreview(vc: NewRequestViewController, url: URL, user: User) {
        goToViewControllerWithIdentifier(identifier: Screen.requestOverview.rawValue) { (vc) in
            if let vc = vc as? RequestOverviewViewController {
                vc.url = url
                vc.user = user
            }
        }
    }
}

extension NewFlowManager: RequestOverviewViewControllerFlowDelegate {
    func requestPreviewHasSentRequest(vc: RequestOverviewViewController) {
        if let vc = requestStartedFromVC {
            navigationController.popToViewController(vc, animated: true)
        }
        
        delegate?.flowDidFinish(flow: self)
    }
}

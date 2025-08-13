//
//  InboxFlowManger.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import Foundation
import UIKit

class InboxFlowManager: BaseFlowManager {

    private enum Screen: String {
        case inbox
        case request
        case earnings
        case conversation
        case reply
        case noAction
        case addToProfile
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Inbox
        }
    }
    
    private let profileFlow: ProfileFlowManager
    private let newFlow: NewFlowManager
    private let miscFlow: MiscFlowManager
    
    // MARK: Overwritten
    
    override init(navigationController: UINavigationController) {
        profileFlow = ProfileFlowManager(navigationController: navigationController)
        newFlow = NewFlowManager(navigationController: navigationController)
        miscFlow = MiscFlowManager(navigationController: navigationController)
        
        super.init(navigationController: navigationController)
        
        profileFlow.delegate = self
        newFlow.delegate = self
    }

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = false
        navigationController.hidesBottomBarWhenPushed = true
        shouldReplaceNavigationStack = true

        goToViewControllerWithIdentifier(identifier: Screen.inbox.rawValue)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? InboxViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? RequestViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? CurrentEarningsViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ConversationViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ReplyViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? NoActionVideoMessageViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? AddVideoToProfileViewController {
            vc.flowDelegate = self
        }
    }
    
    
    // MARK: Private methods
}

extension InboxFlowManager: InboxFlowDelegate {
    func inboxGoToUser(vc: InboxViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
    
    func inboxGoToRequest(vc: InboxViewController) {
        goToViewControllerWithIdentifier(identifier: Screen.request.rawValue)
    }
    
    func inboxGoToEarnings(vc: InboxViewController) {
        goToViewControllerWithIdentifier(identifier: Screen.earnings.rawValue)
    }
    
    func inboxGoToConversation(vc: InboxViewController, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.conversation.rawValue) { viewController in
            if let vc = viewController as? ConversationViewController {
                vc.conversation = conversation
            }
        }
    }
}

extension InboxFlowManager: RequestViewControllerFlowDelegate {
    func requestGoToResponse(vc: RequestViewController, message: VideoMessage, conversation: Conversation) {
        newFlow.startNewResponse(message: message, conversation: conversation)
    }
    
}

extension InboxFlowManager: CurrentEarningsViewControllerFlowDelegate {
    func currentEarningsGoToUser(vc: CurrentEarningsViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
}

extension InboxFlowManager: ConversationViewControllerFlowDelegate {
    func conversationGoToNewInteraction(vc: ConversationViewController, otherUser: User) {
        newFlow.startNewRequest(vc: vc, forUser: otherUser)
    }
    
    func conversationGoToUser(vc: ConversationViewController, user: User) {
        profileFlow.startOtherUserFlow(user: user)
    }
    
    func conversationGoToNoAction(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.noAction.rawValue) { viewController in
            if let vc = viewController as? NoActionVideoMessageViewController {
                vc.message = videoMessage
                vc.conversation = conversation
            }
        }
    }
    
    func conversationGoToReply(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.reply.rawValue) { viewController in
            if let vc = viewController as? ReplyViewController {
                vc.message = videoMessage
                vc.conversation = conversation
            }
        }
    }
    
    func conversationGoToRequest(vc: ConversationViewController, videoMessage: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.request.rawValue) { viewController in
            if let vc = viewController as? RequestViewController {
                vc.message = videoMessage
                vc.conversation = conversation
            }
        }
    }
}

extension InboxFlowManager: ReplyViewControllerFlowDelegate {
    func replyAddMessageToProfile(vc: ReplyViewController, message: VideoMessage, conversation: Conversation) {
        goToViewControllerWithIdentifier(identifier: Screen.addToProfile.rawValue) { viewController in
            if let vc = viewController as? AddVideoToProfileViewController {
                vc.message = message
                vc.conversation = conversation
            }
        }
    }
}

extension InboxFlowManager: NoActionVideoMessageViewControllerFlowDelegate {
    
}

extension InboxFlowManager: AddVideoToProfileViewControllerFlowDelegate {
    func videoWasAddedToProfile(vc: AddVideoToProfileViewController) {
        popToConversation()
    }
    
    func videoSelectCategory(vc: AddVideoToProfileViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate) {
        miscFlow.startCategoryPicker(selectedCategory: selectedCategory, delegate: delegate)
    }
}

extension InboxFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
        
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        // A response has been sent
        if flow === newFlow {
            // Pop to the conversation vc
            popToConversation()
        }
    }
    
    fileprivate func popToConversation() {
        // Pop to the conversation vc
        if let conversationVC = navigationController.viewControllers.last(where: {$0 is ConversationViewController}) as? ConversationViewController {
            conversationVC.scrollToBottomOnLoad = true
            navigationController.popToViewController(conversationVC, animated: true)
        }
    }
}

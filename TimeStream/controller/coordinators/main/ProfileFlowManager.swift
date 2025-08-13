//
//  ProfileFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import Foundation
import UIKit

protocol ProfileFlowActionsDelegate: AnyObject {
    func profileChangePhoneNumber(flow: ProfileFlowManager)
    func profileGoToActivity(flow: ProfileFlowManager)
}

class ProfileFlowManager: BaseFlowManager {
    
    weak var actionsDelegate: ProfileFlowActionsDelegate?

    private enum Screen: String {
        case profile
        case edit
        case payment
        case charity
        case settings
        case otherUser
        
        case followers
        case following
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Profile
        }
    }
    
    private let authNavController = UINavigationController()
    private let miscFlow: MiscFlowManager!
    private let authenticationFlow: AuthenticationFlowManager!
    private let newFlow: NewFlowManager!
    
    // MARK: Overwritten
    
    override init(navigationController: UINavigationController) {
        miscFlow = MiscFlowManager(navigationController: navigationController)
        authenticationFlow = AuthenticationFlowManager(navigationController: authNavController, overlay: true)
        newFlow = NewFlowManager(navigationController: navigationController)
        
        super.init(navigationController: navigationController)
        
        authenticationFlow.delegate = self
        newFlow.delegate = self
    }

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToViewControllerWithIdentifier(identifier: Screen.profile.rawValue)
    }
    
    override func backButtonPressed(from viewController: UIViewController) {
        if navigationController.viewControllers.count == 1 {
            delegate?.flowDidFinish(flow: self)
        }
        
        super.backButtonPressed(from: viewController)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? ProfileViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? EditProfileViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? PaymentDetailsViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? SelectCharityViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? SettingsViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? OtherUserProfileViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? FollowersViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? FollowingViewController {
            vc.flowDelegate = self
        }
    }
    
    // MARK: Methods
    
    func startOtherUserFlow(user: User) {
        goToUser(user: user)
    }
    
    // MARK: Private methods
    
    fileprivate func goToUser(user: User) {
        if let current = Context.current.user,
           current.id == user.id {
            // Navigate to current profile
            goToViewControllerWithIdentifier(identifier: Screen.profile.rawValue) { (vc) in
                if let vc = vc as? ProfileViewController {
                    vc.displayedInNavigation = true
                    vc.hidesBottomBarWhenPushed = true
                }
            }
            
            return
        }
        
        goToViewControllerWithIdentifier(identifier: Screen.otherUser.rawValue) { (vc) in
            if let vc = vc as? OtherUserProfileViewController {
                vc.user = user
            }
        }
    }
    
    fileprivate func goToFollowers(user: User) {
        goToViewControllerWithIdentifier(identifier: Screen.followers.rawValue) { (vc) in
            if let vc = vc as? FollowersViewController {
                vc.forUser = user
            }
        }
    }
    
    fileprivate func goToFollowing(user: User) {
        goToViewControllerWithIdentifier(identifier: Screen.following.rawValue) { (vc) in
            if let vc = vc as? FollowingViewController {
                vc.forUser = user
            }
        }
    }
}

extension ProfileFlowManager: ProfileFlowDelegate {
    func profileGoToCharity(vc: ProfileViewController) {
        navigationController.navigationBar.isHidden = false
        goToViewControllerWithIdentifier(identifier: Screen.payment.rawValue) { viewController in
            if let vc = viewController as? PaymentDetailsViewController {
                vc.shouldEnableCharity = true
            }
        }
    }
    
    func profileGoToActivity(vc: ProfileViewController) {
        actionsDelegate?.profileGoToActivity(flow: self)
    }
    
    func profileGoVideo(vc: ProfileViewController, video: Video) {
        miscFlow.startVideoDetails(video: video)
    }
    
    func profileGoToFollowers(vc: ProfileViewController, user: User) {
        goToFollowers(user: user)
    }
    
    func profileGoToFollowing(vc: ProfileViewController, user: User) {
        goToFollowing(user: user)
    }
    
    func profileEditProfile(vc: ProfileViewController) {
        navigationController.navigationBar.isHidden = false
        goToViewControllerWithIdentifier(identifier: Screen.edit.rawValue)
    }
    
    func profilePaymentDetails(vc: ProfileViewController) {
        navigationController.navigationBar.isHidden = false
        goToViewControllerWithIdentifier(identifier: Screen.payment.rawValue)
    }
    
    func profileSettings(vc: ProfileViewController) {
        navigationController.navigationBar.isHidden = false
        goToViewControllerWithIdentifier(identifier: Screen.settings.rawValue)
    }
}


extension ProfileFlowManager: EditProfileFlowDelegate {
    func editProfileChangeExpertise(vc: EditProfileViewController, category: Category?, delegate: CategoryPickerActionDelegate) {
        miscFlow.startCategoryPicker(selectedCategory: category, delegate: delegate, otherTitle: "select.category.of.main.interest".localized)
    }
    
    func editProfileChangePhoneNumber(vc: EditProfileViewController) {
        actionsDelegate?.profileChangePhoneNumber(flow: self)
    }
}

extension ProfileFlowManager: PaymentDetailsFlowDelegate {

    func paymentDetailsSelectCharity(vc: PaymentDetailsViewController, selection: @escaping CharitySelectionClosure, selectedCharity: Charity?) {
        goToViewControllerWithIdentifier(identifier: Screen.charity.rawValue) { (vc) in
            if let vc = vc as? SelectCharityViewController {
                vc.charitySelectionClosure = selection
                vc.initialySelectedCharity = selectedCharity
            }
        }
    }
    
    func paymentDetailsSelectCharity(vc: PaymentDetailsViewController, selectedCharity: Charity?) {
        goToViewControllerWithIdentifier(identifier: Screen.charity.rawValue) { (vc) in
            if let vc = vc as? SelectCharityViewController {
                vc.initialySelectedCharity = selectedCharity
            }
        }
    }
}

extension ProfileFlowManager: SelectCharityFlowDelegate {
   
}

extension ProfileFlowManager: SettingsFlowDelegate {
    func settingsDidLogOut(vc: SettingsViewController) {
        delegate?.flowDidFinish(flow: self)
    }
   
    func settingGoToPayment(vc: SettingsViewController) {
        goToViewControllerWithIdentifier(identifier: Screen.payment.rawValue)
    }
    
    func settingsGoToWeb(vc: SettingsViewController, title: String, url: URL) {
        miscFlow.startWebPage(title: title, url: url)
    }
    
}

extension ProfileFlowManager: OtherUserFlowDelegate {
    func otherProfileGoRequestVideo(vc: OtherUserProfileViewController, user: User) {
        newFlow.startNewRequest(vc: vc, forUser: user)
    }
    
    func otherProfileGoVideoDetails(vc: OtherUserProfileViewController, video: Video) {
        miscFlow.startVideoDetails(video: video)
    }
    
    func otherProfileAuthenticateUser(vc: OtherUserProfileViewController, completion: @escaping EmptyClosure) {
        authenticationFlow.authenticateIfNeededAndDoAction(from: navigationController) { _ in 
            completion()
        }
    }
    
    func otherProfileGoToFollowers(vc: OtherUserProfileViewController, user: User) {
        goToFollowers(user: user)
    }
    
    func otherProfileGoToFollowing(vc: OtherUserProfileViewController, user: User) {
        goToFollowing(user: user)
    }
}

extension ProfileFlowManager: FollowersViewControllerFlowDelegate {
    func followersGoToUser(vc: FollowersViewController, user: User) {
        goToUser(user: user)
    }
}

extension ProfileFlowManager: FollowingViewControllerFlowDelegate {
    func followingGoToUser(vc: FollowingViewController, user: User) {
        goToUser(user: user)
    }
}

extension ProfileFlowManager: BaseFlowDelegate {
    func flowDidStart(flow: BaseFlowManager) {
        // Do nothing
    }
    
    func flowDidFinish(flow: BaseFlowManager) {
        if flow === authenticationFlow {
            authNavController.dismiss(animated: true, completion: nil)
        }
    }
    
    func flowDidCancel(flow: BaseFlowManager) {
       // Do nothing
    }
}


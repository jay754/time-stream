//
//  AuthenticationFlowManager.swift
//  TimeStream
//
//  Created on 03.07.2021.
//

import Foundation
import UIKit

typealias SimpleAuthClosure = (_ wasPreviouslyAuthenticated: Bool) -> Void

class AuthenticationFlowManager: BaseFlowManager {

    private enum Screen: String {
        case phone
        case code
        case name
        
        case reauthenticateCode
        case reauthenticatePhone
        
        case changePhone
        case changeCode
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Authentication
        }
    }
    
    private var loginSuccessClosure: EmptyClosure?
    
    private let miscFlow: MiscFlowManager!
    private var overlay: Bool = false
    
    // MARK: Overwritten
    
    init(navigationController: UINavigationController, overlay: Bool) {
        miscFlow = MiscFlowManager(navigationController: navigationController)
        self.overlay = overlay

        super.init(navigationController: navigationController)
    }
    
    // MARK: Methods

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = false
        navigationController.hidesBottomBarWhenPushed = false
        shouldReplaceNavigationStack = true

        goToViewControllerWithIdentifier(identifier: Screen.phone.rawValue) { (vc) in
            if let vc = vc as? PhoneViewController {
                vc.overlay = self.overlay
            }
        }
    }
    
    func startLoginWithSuccess(completion: @escaping EmptyClosure) {
        loginSuccessClosure = completion
        
        startFlow()
    }
    
    func authenticateIfNeededAndDoAction(from: UIViewController, action: @escaping SimpleAuthClosure) {
        if Context.current.authenticated {
            // The user is authenticated
            action(true)

            return
        }

        LocalNotifications.issueNotification(type: .pausePlayingVideo)
        startLoginWithSuccess {
            action(false)
        }

        navigationController.modalPresentationStyle = .overFullScreen
        from.getTopViewController().present(navigationController, animated: true, completion: nil)
    }
    
    func startName() {
        navigationController.navigationBar.isHidden = true
        goToViewControllerWithIdentifier(identifier: Screen.name.rawValue)
    }
    
    func startChangePhoneNumber() {
        shouldReplaceNavigationStack = true
        
        goToViewControllerWithIdentifier(identifier: Screen.reauthenticatePhone.rawValue)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? PhoneViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? CodeValidationViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? NameViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ReauthenticatePhoneNumberViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ReauthenticateCodeValidationViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ChangePhoneNumberViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? ChangePhoneNumberValidationViewController {
            vc.flowDelegate = self
        }
    }
    
    override func backButtonPressed(from viewController: UIViewController) {
        if !overlay {
            super.backButtonPressed(from: viewController)
            return
        }
        
        if navigationController.viewControllers.count == 1 {
            loginSuccessClosure = nil
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
    
    // MARK: Private methods
    
    fileprivate func userAuthenticated() {
        // The user is authenticated
        loginSuccessClosure?()
        delegate?.flowDidFinish(flow: self)
    }
}

extension AuthenticationFlowManager: PhoneFlowDelegate {
    
    func phoneFlowHasValidate(vc: PhoneViewController, phoneNumber: String, validationToken: String) {
        goToViewControllerWithIdentifier(identifier: Screen.code.rawValue) { (vc) in
            if let vc = vc as? CodeValidationViewController {
                vc.phoneNumber = phoneNumber
                vc.validationToken = validationToken
            }
        }
    }
}

extension AuthenticationFlowManager: CodeValidationFlowDelegate {
    func codeValidationRegisterUser(vc: CodeValidationViewController) {
        goToViewControllerWithIdentifier(identifier: Screen.name.rawValue)
    }
    
    
    func codeValidationUserAuthenticated(vc: CodeValidationViewController) {
        // The user is authenticated
        userAuthenticated()
    }
}

extension AuthenticationFlowManager: NameFlowDelegate {
    
    func nameGoToWeb(vc: NameViewController, url: URL, title: String) {
        miscFlow.startWebPage(title: title, url: url)
    }
    
    func nameSelectCategory(vc: NameViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate) {
        miscFlow.startCategoryPicker(selectedCategory: selectedCategory, delegate: delegate, otherTitle: "select.category.of.interest".localized)
    }
    
    func nameHasRegisteredANewAccount(vc: NameViewController) {
        userAuthenticated()
    }
}


extension AuthenticationFlowManager: ReauthenticatePhoneNumberFlowDelegate {
    func reauthenticatePhoneHasValidated(vc: ReauthenticatePhoneNumberViewController, phoneNumber: String, validationToken: String) {
        
        goToViewControllerWithIdentifier(identifier: Screen.reauthenticateCode.rawValue) { (vc) in
            if let vc = vc as? ReauthenticateCodeValidationViewController {
                vc.phoneNumber = phoneNumber
                vc.validationToken = validationToken
            }
        }
    }
}

extension AuthenticationFlowManager: ReauthenticateCodeValidationFlowDelegate {
    func reauthenticatePhoneCodeValidationSuccesfullyChanged(vc: ReauthenticateCodeValidationViewController) {
        shouldReplaceNavigationStack = true
        goToViewControllerWithIdentifier(identifier: Screen.changePhone.rawValue)
    }
}

extension AuthenticationFlowManager: ChangePhoneNumberFlowDelegate {
    func changePhoneHasValidated(vc: ChangePhoneNumberViewController, phoneNumber: String, validationToken: String) {
        goToViewControllerWithIdentifier(identifier: Screen.changeCode.rawValue) { (vc) in
            if let vc = vc as? ChangePhoneNumberValidationViewController {
                vc.phoneNumber = phoneNumber
                vc.validationToken = validationToken
            }
        }
    }
}


extension AuthenticationFlowManager: ChangePhoneNumberValidationFlowDelegate {
    func changePhoneCodeValidationSuccesfullyChanged(vc: ChangePhoneNumberValidationViewController) {
        userAuthenticated()
    }
}

//
//  InitialLoadingViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

protocol InitialFlowDelegate: BaseViewControllerFlowDelegate {
    func initialFlowUserAuthenticated(vc: InitialLoadingViewController)
    func initialFlowUserNotAuthenticated(vc: InitialLoadingViewController)
}

class InitialLoadingViewController: BaseViewController {
    
    weak var flowDelegate: InitialFlowDelegate?
    
    private let authService = FirebaseAuthentication()
    private let userService = UserService()
    private let userDefaultsHelper = UserDefaultsHelper()
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleAuth()
    }
    
    // MARK: Private methods

    private func handleAuth() {
        authService.refreshAccessToken { (result) in
            switch result {
            case .error:
                self.flowDelegate?.initialFlowUserNotAuthenticated(vc: self)
                
            case .success(let token):
                self.handleToken(token)
                self.fetchCurrentUser()
            }
        }
    }
    
    private func handleToken(_ token: String) {
        Context.current.accessToken = token
    }
    
    private func fetchCurrentUser() {
        userService.getCurrentUser { (result) in
            switch result {
            case .error:
                Context.current.clearCurrentUserData()
                self.authService.signOut {}
                self.flowDelegate?.initialFlowUserNotAuthenticated(vc: self)
                
            case .success(let user):
                self.update(user: user)
            }
        }
    }
    
    private func update(user: User) {
        var newUser = user
        newUser.currency = Currency.current()
        newUser.fcmToken = PushNotificationsManager.instance.pushNotificationsToken
        
        if newUser.categoriesOfInterest.count < 3 {
            newUser.categoriesOfInterest = userDefaultsHelper.getCategories() ?? newUser.categoriesOfInterest
        }
        
        userService.updateUserPreferences(user: newUser) { (result) in
            switch result {
            case .error:
                Context.current.clearCurrentUserData()
                self.authService.signOut {}
                self.flowDelegate?.initialFlowUserNotAuthenticated(vc: self)
                
            case .success(let user):
                Context.current.user = user
                self.flowDelegate?.initialFlowUserAuthenticated(vc: self)
            }
        }
    }
}

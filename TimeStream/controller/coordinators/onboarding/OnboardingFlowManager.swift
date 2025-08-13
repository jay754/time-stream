//
//  OnboardingFlowManager.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

class OnboardingFlowManager: BaseFlowManager {

    private enum Screen: String {
        case initial
        case onboarding
        case categories
    }
    
    override var storyboardName: StoryboardName {
        get {
            .Onboarding
        }
    }
    
    private var categoriesSelectedClosure: EmptyClosure?
    private let userDefaultsHelper = UserDefaultsHelper()

    override func startFlow() {
        super.startFlow()
        
        navigationController.navigationBar.isHidden = true
        navigationController.hidesBottomBarWhenPushed = true

        goToViewControllerWithIdentifier(identifier: Screen.initial.rawValue)
    }
    
    override func setDelegates(for viewController: UIViewController) {
        if let vc = viewController as? OnboardingViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? InitialLoadingViewController {
            vc.flowDelegate = self
        }
        
        if let vc = viewController as? CategoriesSelectorViewController {
            vc.flowDelegate = self
        }
    }
    
    
    // MARK: Private methods
    
    private func goToCategories(completion: @escaping EmptyClosure) {
        categoriesSelectedClosure = completion
        navigationController.navigationBar.isHidden = true
        goToViewControllerWithIdentifier(identifier: Screen.categories.rawValue)
    }
}

extension OnboardingFlowManager: OnboardingFlowDelegate {
    
    func onboardingFinished(vc: OnboardingViewController) {
        userDefaultsHelper.set(boolean: true, key: .hasShownOnboarding)
        
        handleCategoriesIfNeeded {
            self.delegate?.flowDidFinish(flow: self)
        }
    }
}

extension OnboardingFlowManager: InitialFlowDelegate {
    func initialFlowUserAuthenticated(vc: InitialLoadingViewController) {
        handleCategoriesIfNeeded {
            self.delegate?.flowDidFinish(flow: self)
        }
    }
    
    func initialFlowUserNotAuthenticated(vc: InitialLoadingViewController) {
        // Check if has picked categories
        if !userDefaultsHelper.getBoolean(key: .hasShownOnboarding) {
            goToViewControllerWithIdentifier(identifier: Screen.onboarding.rawValue)
            return
        }
        
        handleCategoriesIfNeeded {
            self.delegate?.flowDidFinish(flow: self)
        }
    }
    
    private func handleCategoriesIfNeeded(completion: @escaping EmptyClosure) {
        if let categories = userDefaultsHelper.getCategories(),
           categories.count > 2 {
            
            // All good nothing to do, continue
            completion()
            return
        }
        
        if let user = Context.current.user,
           user.categoriesOfInterest.count > 2 {
            
            // All good nothing to do, continue
            completion()
            return
        }
        
        // Categories were not selected
        goToCategories(completion: completion)
    }
}

extension OnboardingFlowManager: CategoriesSelectorFlowDelegate {
    
    func categoriesWereSelected(vc: CategoriesSelectorViewController) {
        categoriesSelectedClosure?()
    }
}


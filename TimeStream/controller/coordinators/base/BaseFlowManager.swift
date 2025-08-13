//
//  BaseFlowManager.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import Foundation
import UIKit

typealias setupControllerColosure = (_ viewController:UIViewController) -> Void

protocol FlowManagerProtocol: class {
    func goToViewControllerWithIdentifier(identifier: String, setupClosure: setupControllerColosure?)
}

protocol BaseFlowDelegate: class {
    func flowDidStart(flow: BaseFlowManager)
    func flowDidFinish(flow: BaseFlowManager)
    func flowDidCancel(flow: BaseFlowManager)
    
}

class BaseFlowManager: FlowManagerProtocol, BaseViewControllerFlowDelegate {
    let navigationController: UINavigationController
    
    // !! Must be overwritten by children
    var storyboardName: StoryboardName {
        get {
            fatalError("The storyboard name must be overwritten")
        }
    }
    
    // If this is set to true, the first screen will replace all navigation stack
    var shouldReplaceNavigationStack = false
    var shouldAppendToNavigationStack = false
    
    weak var delegate: BaseFlowDelegate?
    
    // MARK: Lifecycle
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: Public Methods
    
    func startFlow() {
        delegate?.flowDidStart(flow: self)
    }
    
	func pushViewController(_ viewController: UIViewController, animated: Bool = true)  {
        if shouldAppendToNavigationStack {
            shouldAppendToNavigationStack = false
            
            navigationController.viewControllers.append(viewController)
            return
        }
        
        if shouldReplaceNavigationStack {
            shouldReplaceNavigationStack = false
            
            navigationController.setViewControllers([viewController], animated: false)
        } else {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    func pushScreenWithIdentifier(identifier: String, setupClosure: setupControllerColosure? = nil) {
        let viewController = viewControllerFor(storyboardName: storyboardName, identifier: identifier)
        
        if let block = setupClosure {
            block(viewController)
        }
        
        pushViewController(viewController)
    }
    
    // MARK: Delegate
    
    func goToViewControllerWithIdentifier(identifier: String, setupClosure: setupControllerColosure? = nil) {
        pushScreenWithIdentifier(identifier: identifier, setupClosure: setupClosure)
    }
    
    // MARK: Base View Controller Flow Delegate
    
    func backButtonPressed(from viewController:UIViewController) {
        //!! This should be overriten in case of another behaviour
        navigationController.popViewController(animated: true)
    }
    
    // MARK: Protected Methods
    
    func viewControllerFor(storyboardName: StoryboardName, identifier:String) -> UIViewController {
        let vc = StoryboardHelper.viewControllerFromStoryboard(name: storyboardName, identifier: identifier)
        
        setDelegates(for: vc)
        
        return vc
    }
    
    func viewControllersFor(storyboardName: StoryboardName, identifiers: [String]) -> [UIViewController] {
        var viewControllers = [UIViewController]()
        
        for identifier in identifiers {
            let vc = viewControllerFor(storyboardName: storyboardName, identifier: identifier)
            
            viewControllers.append(vc)
        }
        
        return viewControllers
    }
    
    func setDelegates(for viewController:UIViewController) {
        // Must be overwritten for custom behaviour
    }
}

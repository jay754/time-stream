//
//  UIViewController+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

extension UIViewController {
    
    // MARK: Alerts
    
    func showGenericError() {
        AlertHelper.displayMessageOnTopOfEverything("something.went.wrong".localized, title: "oops".localized)
    }
    
    func showAlert(title: String = "Info", message: String, completion: EmptyClosure? = nil) {
        AlertHelper.displayMessageOnTopOfEverything(message, title: title, completion: completion)
    }
    
    // MARK: Navigation bar
    
    func addBackButton(selector: Selector) {
        let image = UIImage(named: "back-icon")
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 10
        
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: selector)
        
        navigationItem.setLeftBarButtonItems([item], animated: false)
    }
    
    func addCloseButton(selector: Selector) {
        let image = UIImage(named: "close-icon")
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: selector)
        
        navigationItem.setRightBarButton(item, animated: false)
    }
    
    func removeLeftNavBarIcon() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = nil
        navigationItem.backBarButtonItem = nil
    }
    
    func addRightButton(title: String, selector: Selector) {
        let item =  UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
        
        navigationItem.setRightBarButton(item, animated: false)
    }
    
    func getTopViewController() -> UIViewController {
        var topViewController = self
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
    
}

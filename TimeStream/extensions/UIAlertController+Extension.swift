//
//  UIAlertController+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

fileprivate class AlertContainerViewController: UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var activityIndicator = "xxx_window"
    }
    
    var xxx_window: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIWindow
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.activityIndicator,
                    newValue as UIWindow?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    func showOnANewWindow() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate else {
            
            return
        }
        
        xxx_window = UIWindow(windowScene: scene)
        xxx_window?.rootViewController = AlertContainerViewController()
        
        if let topWindow = delegate.window {
            xxx_window?.windowLevel = topWindow.windowLevel + 1
            
            xxx_window?.makeKeyAndVisible()
            xxx_window?.rootViewController?.present(self, animated: true, completion: nil)
        }
    }
}

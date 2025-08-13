//
//  TabBarViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit

protocol TabBarViewControllerDelegate: class {
    func shouldSelectTab(viewController: UIViewController) -> Bool
    func changedTabBarItem(viewController: UIViewController)
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    weak var authenticationDelegate: TabBarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
 
        tabBar.clipsToBounds = true
        view.backgroundColor = .white
        
        delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }

        let timeInterval: TimeInterval = 0.3
        let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.5) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
        propertyAnimator.startAnimation()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let delegate = authenticationDelegate else {
            return true
        }

        return delegate.shouldSelectTab(viewController: viewController)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        authenticationDelegate?.changedTabBarItem(viewController: viewController)
    }
}

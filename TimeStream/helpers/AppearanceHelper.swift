//
//  AppearanceHelper.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

class AppearanceHelper {

    static func configureNavigationBar() {
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            
            navigationBarAppearance.backgroundColor = UIColor.white
            navigationBarAppearance.shadowImage = UIImage()
            navigationBarAppearance.backgroundImage = UIImage()
            
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text,
                                                                NSAttributedString.Key.font: UIFont.defaultFontMedium(ofSize: 17)]
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        UINavigationBar.appearance().tintColor = UIColor.text
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text,
                                                            NSAttributedString.Key.font: UIFont.defaultFontMedium(ofSize: 17)]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.text,
                                                             NSAttributedString.Key.font: UIFont.defaultFontMedium(ofSize: 17)], for: .normal)
    }
    
    static func configureNavBarAssetPicking() {
        UINavigationBar.appearance().tintColor = UIColor.text
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text,
                                                            NSAttributedString.Key.font: UIFont.defaultFontMedium(ofSize: 17)]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.text,
                                                             NSAttributedString.Key.font: UIFont.defaultFontMedium(ofSize: 17)], for: .normal)
    }
    
    
    static func configureTabBar() {
        let tabBarAtributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
                               NSAttributedString.Key.font : UIFont.defaultFont(ofSize: 12)]
        
        UITabBarItem.appearance().setTitleTextAttributes(tabBarAtributes,
                                                         for: UIControl.State.normal)
        UITabBarItem.appearance().setTitleTextAttributes(tabBarAtributes,
                                                         for: UIControl.State.selected)
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.white
    }
}

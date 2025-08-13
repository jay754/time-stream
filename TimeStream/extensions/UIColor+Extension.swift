//
//  UIColorExtension.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import Foundation
import UIKit

extension UIColor {
    
    static var accent: UIColor {
        return UIColor.init(named: "accent-color")!
    }
    
    static var secondaryAccent: UIColor {
        return UIColor.init(named: "accent-secondary-color")!
    }
    
    static var text: UIColor {
        return UIColor.init(named: "text-main-color")!
    }
    
    static var secondaryText: UIColor {
        return UIColor.init(named: "text-secondary-color")!
    }
    
    static var unselectedContainerColor: UIColor {
        return UIColor.init(named: "unselected-container-color")!
    }
    
    static var unselectedContainerText: UIColor {
        return UIColor.init(named: "unselected-container-text")!
    }
    
    static var backgroundColor: UIColor {
        return UIColor.init(named: "background-color")!
    }
    
    static var darkBackgroundColor: UIColor {
        return UIColor.init(named: "dark-background-color")!
    }
    
    static var destroyColor: UIColor {
        return UIColor.init(named: "destroy-color")!
    }
    
    static var tertiaryAccentColor: UIColor {
        return UIColor.init(named: "accent-tertiary-color")!
    }
    
    static var textMainPlaceholderColor: UIColor {
        return UIColor.init(named: "text-main-placeholder-color")!
    }
  
}


extension UIColor {
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 {
            self.init("ff0000") // return red color for wrong hex input
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

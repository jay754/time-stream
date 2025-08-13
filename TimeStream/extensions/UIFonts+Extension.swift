//
//  UIFonts+Extension.swift
//  OneSave
//
//  Created by appssemble on 02.03.2021.
//

import UIKit

extension UIFont {
    
    static func defaultFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactRounded-Regular", size: ofSize)!
    }
    
    static func defaultFontMedium(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactRounded-Medium", size: ofSize)!
    }
    
    static func defaultFontSemiBold(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactRounded-Semibold", size: ofSize)!
    }
    
    static func defaultFontBold(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "SFCompactRounded-Bold", size: ofSize)!
    }
    
    
    static func listFonts() {
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
    }
    
}

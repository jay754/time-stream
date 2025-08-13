//
//  NSAttributedString+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 14.05.2021.
//

import UIKit


extension NSAttributedString {
    
    static func underlineText(text: String, bolded: [String], fontSize: CGFloat = 21, accentColor: UIColor) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.text  as Any,
                          NSAttributedString.Key.font: UIFont.defaultFontBold(ofSize: fontSize) as Any]
        
        var boldText = attributes
        boldText[NSAttributedString.Key.foregroundColor] = accentColor
        boldText[NSAttributedString.Key.font] = UIFont.defaultFontBold(ofSize: fontSize)
        boldText[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        
        
        let returnString = NSMutableAttributedString(string: text as String, attributes:attributes)
        for i in 0 ..< bolded.count {
            
            for boldedRange in returnString.string.ranges(of: bolded[i]) {
                let nsRange = NSRange(boldedRange, in: returnString.string)
                
                returnString.addAttributes(boldText, range: nsRange)
            }
        }
        
        return returnString
    }
    
    
    static func authenticationAttributes(text: String, bolded: [String], fontSize: CGFloat = 17, accentColor: UIColor) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryText  as Any,
                          NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize) as Any]
        
        var boldText = attributes
        boldText[NSAttributedString.Key.foregroundColor] = accentColor
        boldText[NSAttributedString.Key.font] = UIFont.defaultFontSemiBold(ofSize: fontSize)
        
        
        let returnString = NSMutableAttributedString(string: text as String, attributes:attributes)
        for i in 0 ..< bolded.count {
            
            for boldedRange in returnString.string.ranges(of: bolded[i]) {
                let nsRange = NSRange(boldedRange, in: returnString.string)
                
                returnString.addAttributes(boldText, range: nsRange)
            }
        }
        
        return returnString
    }
    
    
    static func hyperlinkText(text: String, underlined: [String], links: [URL], fontSize: CGFloat = 12, accentColor: UIColor = UIColor.secondaryAccent) -> NSAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryText  as Any,
                          NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize) as Any,
                          NSAttributedString.Key.paragraphStyle: paragraph]
        
        var boldText = attributes
        boldText[NSAttributedString.Key.foregroundColor] = accentColor
        boldText[NSAttributedString.Key.font] = UIFont.defaultFontMedium(ofSize: fontSize)
        
        let returnString = NSMutableAttributedString(string: text as String, attributes:attributes)
        for i in 0 ..< underlined.count {
            
            for boldedRange in returnString.string.ranges(of: underlined[i]) {
                let nsRange = NSRange(boldedRange, in: returnString.string)
                
                var currentBold = boldText
                currentBold[.link] = links[i]
                
                returnString.addAttributes(currentBold, range: nsRange)
            }
        }
        
        return returnString
    }
    
    
    static func placeholderText(text: String, light: [String]) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.textMainPlaceholderColor  as Any,
                          NSAttributedString.Key.font: UIFont.defaultFontSemiBold(ofSize: 17) as Any]
        
        var boldText = attributes
        boldText[NSAttributedString.Key.foregroundColor] = UIColor.textMainPlaceholderColor
        boldText[NSAttributedString.Key.font] = UIFont.defaultFont(ofSize: 15)
        
        
        let returnString = NSMutableAttributedString(string: text as String, attributes:attributes)
        for i in 0 ..< light.count {
            
            for boldedRange in returnString.string.ranges(of: light[i]) {
                let nsRange = NSRange(boldedRange, in: returnString.string)
                
                returnString.addAttributes(boldText, range: nsRange)
            }
        }
        
        return returnString
    }
    
}

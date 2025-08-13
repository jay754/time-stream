//
//  UILabel+Exteension.swift
//  FlexiPass
//
//  Created by appssemble on 28.05.2021.
//

import UIKit

extension UILabel {
    
    @IBInspectable var letterSpacing: CGFloat {
        get {
            var range:NSRange = NSMakeRange(0, text?.count ?? 0)
            let nr = self.attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: &range) as! NSNumber
            return CGFloat(truncating: nr)
        }
        
        set {
            let range:NSRange = NSMakeRange(0, text?.count ?? 0)
            
            let attributedString = NSMutableAttributedString(string: text ?? "")
            attributedString.addAttribute(NSAttributedString.Key.kern, value: newValue, range: range)
            self.attributedText = attributedString
        }
    }
    
    
    
    @IBInspectable var rowsSpacing: CGFloat {
        set {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = newValue
            let attributedString = NSAttributedString(string: text ?? "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            self.attributedText = attributedString
        }
        
        get {
            var range:NSRange = NSMakeRange(0, text?.count ?? 0)
            let nr = self.attributedText?.attribute(NSAttributedString.Key.paragraphStyle, at: 0, effectiveRange: &range) as! NSParagraphStyle
            return CGFloat(truncating: NSNumber(nonretainedObject: nr.lineSpacing))
        }
    }
}

//
//  UITextField+Extension.swift
//  Places
//
//  Created by appssemble on 10/06/2020.
//  Copyright © 2020 Appssemble. All rights reserved.
//

import Foundation
import UIKit
private var __maxLengths = [UITextField: Int]()

extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    func addTextChangeObserver(item: Any, selector: Selector) {
        addTarget(item, action: selector, for: .editingChanged)
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return Int.max // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    
    @objc
    func fix(textField: UITextField) {
        let t = textField.text?.prefix(maxLength) ?? ""
        
        textField.text = String(t)
    }
}

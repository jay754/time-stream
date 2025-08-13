//
//  NSLayoutConstraint+Extension.swift
//  Company space planner
//
//  Created by appssemble on 19/05/2020.
//  Copyright © 2020 Zenitech. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    
    @IBInspectable var iphone5Constraint: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPhone5Size {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iphoneNormalConstraint: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPhone6Size {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iphonePlusConstraint: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPhone6PlusSize {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iphoneXConstraint: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPhoneXSize {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iPadNormal: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPadNormal {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iPadPro10: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPadPro10 {
                self.constant = newValue
            }
        }
    }
    
    @IBInspectable var iPadPro12: CGFloat {
        get {
            return self.constant
        }
        
        set {
            if UIDevice().screenType == .iPadPro12 {
                self.constant = newValue
            }
        }
    }
}

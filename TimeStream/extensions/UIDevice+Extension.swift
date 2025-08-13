//
//  UIDevice+Extension.swift
//  Company space planner
//
//  Created by appssemble on 19/05/2020.
//  Copyright © 2020 Zenitech. All rights reserved.
//

import UIKit

enum ScreenType: String {
    case iPhone4Size
    case iPhone5Size
    case iPhone6Size
    case iPhone6PlusSize
    case iPhoneXSize
    
    case iPadNormal
    case iPadPro10
    case iPadPro12
    
    case unknown
}

extension UIDevice {
    
    static var isSimulator: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()
    
    
    var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    var iPad: Bool {
        return UIDevice().userInterfaceIdiom == .pad
    }
    
    var screenType: ScreenType {

        if iPhone {
            return phoneDeviceType
        }
        
        if iPad {
            return padDeviceType
        }
        
        return .unknown
    }
    
    // MARK: Private
    
    private var padDeviceType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1112:
            return .iPadPro10
        case 1366:
            return .iPadPro12
        default:
            return .iPadNormal
        }
    }
    
    private var phoneDeviceType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4Size
        case 1136:
            return .iPhone5Size
        case 1334:
            return .iPhone6Size
        case 2208:
            return .iPhone6PlusSize
        case 2436:
            return .iPhoneXSize
        default:
            return .unknown
        }
    }
}

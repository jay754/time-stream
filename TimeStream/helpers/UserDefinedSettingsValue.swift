//
//  UserDefinedSettingsValue.swift
//  TimeStream
//
//  Created by appssemble on 11.02.2022.
//

import Foundation


enum UserDefinedSettingsValue: String {
    case STRIPE_KEY
    case ENDPOINT
}

class UserDefinedSettings {
    
    static func valueFor(_ key: UserDefinedSettingsValue) -> String {
        // If the value does not exist, the app should crash, this should never happen
        let dict = Bundle.main.infoDictionary
        let value = dict?[key.rawValue] as! String
        
        return value
    }
}

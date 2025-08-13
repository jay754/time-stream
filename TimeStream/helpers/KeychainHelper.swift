//
//  KeychainHelper.swift
//  FlexiPass
//
//  Created by appssemble on 28.05.2021.
//

import Foundation
import KeychainAccess

enum KeychainKey: String {
    case sessionID
    
    // TODO: Delete me
    case customer
}

class KeychainHelper {
    
    let keychainAccess = Keychain(service: "com.appssemble.timestream")
    
    func getString(key: KeychainKey) -> String? {
        return keychainAccess[key.rawValue]
    }
    
    func setString(value: String?, key: KeychainKey) {
        keychainAccess[key.rawValue] = value
    }
}

//
//  UserDefaultsHelper.swift
//  FlexiPass
//
//  Created on 12.05.2021.
//

import Foundation

public enum UserDefaultsKeys: String {
    case to_be_filled
    
    case hasShownOnboarding
    case selectedCategories
}

@objc
public class UserDefaultsHelper: NSObject {
    
    private let userDefaultsGroup: UserDefaults
    
    override init() {
        userDefaultsGroup = UserDefaults.standard
        
        super.init()
    }
    
    func set(string:String, key: UserDefaultsKeys) {
        userDefaultsGroup.setValue(string, forKey:key.rawValue)
        userDefaultsGroup.synchronize()
    }
    
    func set(categories: [Category]) {
        set(array: categories.map({$0.rawValue}), key: .selectedCategories)
    }
    
    func getCategories() -> [Category]? {
        if let values = getStringArray(key: .selectedCategories) {
            return values.compactMap({Category(rawValue: $0)})
        }
        
        return nil
    }
    
    func getString(key: UserDefaultsKeys) -> String? {
        if let string = userDefaultsGroup.value(forKey: key.rawValue) as? String {
            return string
        }
        
        return nil
    }
    
    func containsItemFor(key: UserDefaultsKeys) -> Bool {
        let hasKey = userDefaultsGroup.object(forKey: key.rawValue)
        
        return hasKey != nil
    }
    
    func set(boolean:Bool, key: UserDefaultsKeys) {
        userDefaultsGroup.set(boolean, forKey: key.rawValue)
        userDefaultsGroup.synchronize()
    }
    
    func getBoolean(key: UserDefaultsKeys) -> Bool {
        return userDefaultsGroup.bool(forKey: key.rawValue)
    }
    
    func set(value:Int, key: UserDefaultsKeys) {
        userDefaultsGroup.set(value, forKey: key.rawValue)
        userDefaultsGroup.synchronize()
    }
    
    func getInt(key: UserDefaultsKeys) -> Int {
        return userDefaultsGroup.integer(forKey: key.rawValue)
    }
    
    func set(array:[String], key: UserDefaultsKeys) {
        userDefaultsGroup.setValue(array, forKey:key.rawValue)
        userDefaultsGroup.synchronize()
    }
    
    func remove(key: UserDefaultsKeys) {
        userDefaultsGroup.removeObject(forKey: key.rawValue)
        userDefaultsGroup.synchronize()
    }
    
    func getStringArray(key: UserDefaultsKeys) -> [String]? {
        if let string = userDefaultsGroup.value(forKey: key.rawValue) as? [String] {
            return string
        }
        
        return nil
    }
    
}

//
//  Context.swift
//  TimeStream
//
//  Created  on 03.07.2021.
//

import Foundation

class Context {
    
    static let current = Context()
    
    private let userDefaultsHelper = UserDefaultsHelper()
    
    // MARK: Properties
    var accessToken: String? {
        didSet {
            print("token:\(accessToken)")
        }
    }
    
    var authenticated: Bool {
        get {
            return accessToken != nil
        }
    }
    
    var user: User? {
        didSet {
            LocalNotifications.issueNotification(type: .userChanged)
        }
    }
    
    var categories: [Category] {
        get {
            if let categs = user?.categoriesOfInterest {
                return categs
            }
            
            return userDefaultsHelper.getCategories() ?? []
        }
    }

    // MARK: Lifecycle
    
    private init() {}
    
    // MARK: Methods
    
    func clearCurrentUserData() {
        accessToken = nil
        user = nil
    }
}

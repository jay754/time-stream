//
//  User.swift
//  TimeStream
//
//  Created by appssemble on 04.07.2021.
//

import Foundation

enum Currency: String {
    case EUR = "EUR"
    case USD = "USD"
    case GBP = "GBP"
    
    static func current() -> Currency {
        if let code = NSLocale.current.currencyCode,
           let currency = Currency(rawValue: code) {
            
            return currency
        }
        
        return .USD
    }
    
    func sign() -> String {
        switch self {
        case .EUR:
            return "€"
        case .GBP:
            return "£"
        case .USD:
            return "$"
        }
    }
    
    func locale() -> Locale {
        switch self {
        case .EUR:
            return Locale(identifier: "de_DE")
            
        case .GBP:
            return Locale(identifier: "en_GB")
            
        case .USD:
            return Locale(identifier: "en_US")
        }
        
        
    }
}

struct User {
    let id: Int
    let firebaseID: String
    let name: String
    let phoneNumber: String
    let photoURL: URL?
    
    let bio: String?

    // Counts
    let followers: Int
    let following: Int
    let tipsEnabled: Bool

    // This will be 0 if interactions are disabled
    var availableInteractions: Int
    
    let createdAt: Date
    let donationsAllowed: Bool
    let price: Int? // THIS IS EXPRESSED IN CENTS (200 - 2$)
    
    var charity: Charity?
    
    var currency: Currency
    
    var expertise: Category
    
    var paymentDetailsCollected: Bool
    
    var followingIDs = [Int]()
    var fcmToken: String? = nil
    var donationPercentage: Int?
    var tags = [String]()
    var categoriesOfInterest = [Category]()
    var username: String
    
    var formattedPrice: String {        
        return price?.formattedPrice(currency: currency) ??  "\(0)" + " \(currency.sign())"
    }
    
    func followsUser(id: Int) -> Bool {
        return followingIDs.contains(id)
    }
}

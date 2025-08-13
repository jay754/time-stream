//
//  UserMapper.swift
//  TimeStream
//
//  Created by appssemble on 04.07.2021.
//

import Foundation


class UserMapper {
    
    private struct Constants {
        static let user = "user"
        static let users = "users"
        
        static let id = "id"
        static let name = "name"
        static let firebaseID = "firebase_id"
        static let phone = "phone_number"
        
        static let uploadURL = "upload_url"
        static let fileName = "file_name"
        static let path = "path"
        static let photoPath = "photo_path"
        static let photoURL = "photo_url"
        
        static let createdAt = "created_at"
        static let bio = "bio"
        static let availableInteractions = "available_interactions"
        static let tipsEnabled = "tips_enabled"
        static let numberOfTips = "number_of_tips"
        static let followers = "followers"
        static let following = "following"
        static let madeIntaractions = "made_interactions"
        static let currency = "currency"
        static let followingIDs = "following_ids"
        static let FCM_Token = "FCM_token"
        static let donationPercengate = "donation_percentage"
        static let charity = "charity"
        static let donationsAllowed = "allows_donations"
        static let charityID = "charity_id"
        static let price = "price"
        static let tags = "tags"
        static let totalNumberOfLikes = "total_number_of_likes"
        
        static let currencyCode = "currency_code"
        
        static let interactions = "interactions"
        static let categoriesOfInterest = "categories_of_interest"
        
        static let expertise = "expertise"
        static let paymentDetailsCollected = "payment_details_collected"
        
        static let username = "username"
    }
    
    private let charityMapper = CharityMapper()
    
    
    func mapUserFromAuthResponse(dict: [String: Any]) -> User? {
        guard let userDict = dict[Constants.user] as? [String: Any] else {
            return nil
        }
        
        return mapUser(dict: userDict)
    }
    
    func currencyCodeParams(code: String) -> [String: Any] {
        return [Constants.currencyCode: code]
    }
    
    func nameParam(name: String) -> [String: Any] {
        return [Constants.name: name]
    }
    
    func mapUserFromUsersArray(dict: [String: Any]) -> [User]? {
        guard let array = dict[Constants.users] as? [[String: Any]] else {
            return nil
        }
        
        var users = [User]()
        
        for dict in array {
            if let user = mapUser(dict: dict) {
                users.append(user)
            }
        }
        
        return users
    }
    
    func mapTotalNumberOfLikes(dict: [String: Any]) -> (likes: Int, interactions: Int)? {
        guard let likes = dict[Constants.totalNumberOfLikes] as? Int,
              let interacts = dict[Constants.interactions] as? Int else {
                  return nil
              }
        
        return (likes: likes, interactions: interacts)
    }
    
    func createUserDict(name: String, currency: Currency, token: String?, categories: [Category], expertise: Category) -> [String: Any] {
        return [Constants.name: name,
                Constants.FCM_Token: token,
                Constants.categoriesOfInterest: categories.map({$0.rawValue}),
                Constants.expertise: expertise.rawValue,
                Constants.currency: currency.rawValue]
    }
    
    func updateUserDict(user: User) -> [String: Any] {
        return [Constants.name: user.name,
                Constants.availableInteractions: user.availableInteractions,
                Constants.currency: user.currency.rawValue,
                Constants.bio: user.bio,
                Constants.FCM_Token: user.fcmToken,
                Constants.donationPercengate: user.donationPercentage,
                Constants.charityID: user.charity?.id,
                Constants.categoriesOfInterest: user.categoriesOfInterest.map({$0.rawValue}),
                Constants.expertise: user.expertise.rawValue,
                Constants.price: user.price]
    }
    
    func IDDictionary(user: User) -> [String: Any] {
        return [Constants.id: user.id]
    }
    
    func mapURLFromResponse(dict: [String: Any]) -> PresignedUpload? {
        guard let urlStr = dict[Constants.uploadURL] as? String,
              let fileName = dict[Constants.fileName] as? String,
              let path = dict[Constants.path] as? String,
              let url = URL(string: urlStr) else {
            
            return nil
        }
        
        return PresignedUpload(url: url, fileName: fileName, path: path)
    }
    
    func mapUser(dict: [String: Any]) -> User? {
        
        guard let id = dict[Constants.id] as? Int,
              let name = dict[Constants.name] as? String,
              let firebaseID = dict[Constants.firebaseID] as? String,
              let phone = dict[Constants.phone] as? String,
              let tipsAvailable = dict[Constants.tipsEnabled] as? Bool,
              let createdAtString = dict[Constants.createdAt] as? String,
              let createdAt = Date.dateFromBackend(string: createdAtString),
              let followers = dict[Constants.followers] as? Int,
              let currency = dict[Constants.currency] as? String,
              let currencyValue = Currency(rawValue: currency),
              let expertiseStr = dict[Constants.expertise] as? String,
              let expertise = Category(rawValue: expertiseStr),
              let allowsDonations = dict[Constants.donationsAllowed] as? Bool,
              let paymentDetailsCollected = dict[Constants.paymentDetailsCollected] as? Bool,
              let username = dict[Constants.username] as? String,
              let following = dict[Constants.following] as? Int else {
            
            return nil
        }
        
        var photoURL: URL?
        
        if let photoPath = dict[Constants.photoURL] as? String,
           let url = URL(string: photoPath) {
            photoURL = url
        }

        var categoriesOfInterest = [Category]()
        if let categs = dict[Constants.categoriesOfInterest] as? [String] {
            categoriesOfInterest = categs.compactMap({Category(rawValue: $0)})
        }
        
        let availableInteractions = dict[Constants.availableInteractions] as? Int ?? 0
        let bio = dict[Constants.bio] as? String
        let followingIDs = dict[Constants.followingIDs] as? [Int] ?? [Int]()
        let fcmToken = dict[Constants.FCM_Token] as? String
        let donationPercengate = dict[Constants.donationPercengate] as? Int
        let price = dict[Constants.price] as? Int
        let tags = dict[Constants.tags] as? [String] ?? [String]()
        
        var user = User(id: id, firebaseID: firebaseID, name: name, phoneNumber: phone, photoURL: photoURL, bio: bio, followers: followers, following: following, tipsEnabled: tipsAvailable, availableInteractions: availableInteractions, createdAt: createdAt, donationsAllowed: allowsDonations, price: price, currency: currencyValue, expertise: expertise, paymentDetailsCollected: paymentDetailsCollected, username: username)
        
        user.followingIDs = followingIDs
        user.fcmToken = fcmToken
        user.donationPercentage = donationPercengate
        user.charity = charityMapper.mapCharity(dict: dict[Constants.charity] as? [String: Any] ?? [:])
        user.tags = tags
        user.categoriesOfInterest = categoriesOfInterest
        
        return user
    }
    
    // MARK: Private methods
    
}

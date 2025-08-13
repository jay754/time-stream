//
//  UserService.swift
//  TimeStream
//
//  Created by appssemble on 04.07.2021.
//

import UIKit

typealias UserClosure = (_ result: Result<User>) -> Void
typealias UsersClosure = (_ result: Result<[User]>) -> Void
typealias URLClosure = (_ result: Result<PresignedUpload>) -> Void
typealias ShareURL = (_ url: URL?) -> Void
typealias IntClosure = (_ result: Result<Int>) -> Void

typealias LikesAndInteractionsClosure = (_ result: Result<(likes: Int, interactions: Int)>) -> Void

class UserService {
    
    private struct Constants {
        static let users = "users/"
        
        static let currentUser = users + "current"
        static let create = users + "create"
        static let update = users + "update"
        static let updateUserPreferences = users + "update_user_preferences"
        static let follow = users + "follow_user"
        static let unfollow = users + "unfollow_user"
        static let followers = users + "followers/"
        static let followees = users + "followees/"
        static let getByID = users + "get_by_id/"
        static let getByUsername = users + "get_by_username/"
        static let logout = users + "logout"
        static let totalNumberOfLikesAndInteractions = users + "total_number_of_likes_and_interactions/"
        static let searchUser = users + "search_users"
        
        static let testPushNotification = users + "send_test_push"
        
        static let photoUploadURL = users + "presigned_photo_url"
        static let videoUploadURL = users + "presigned_video_url"
        
        static let deleteUser = users + "delete"
    }
    
    private let service = ServiceHelper()
    private let mapper = UserMapper()
    
    // MARK: Methods
    
    func getCurrentUser(completion: @escaping UserClosure) {
        service.GET(path: Constants.currentUser, data: nil) { (result) in
            self.handleUserResponse(result: result, completion: completion)
        }
    }
    
    func searchUser(name: String, completion: @escaping UsersClosure) {
        let params = mapper.nameParam(name: name)
        
        service.GET(path: Constants.searchUser, data: params) { (result) in
            self.handleUsersResponse(result: result, completion: completion)
        }
    }
    
    func getTotalNumberOfLikesAndInteractions(userID: Int, completion: @escaping LikesAndInteractionsClosure) {
        let path = Constants.totalNumberOfLikesAndInteractions + "\(userID)"
        service.GET(path: path, data: nil) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let values = self.mapper.mapTotalNumberOfLikes(dict: dict) else {
                    completion(.error(nil))
                    
                    return
                }
                
                completion(.success(values))
            }
        }
    }
    
    func getUser(id: Int, currencyCode: String, completion: @escaping UserClosure) {
        service.GET(path: Constants.getByID + "\(id)", data: mapper.currencyCodeParams(code: currencyCode)) { (result) in
            self.handleUserResponse(result: result, completion: completion)
        }
    }
    
    func getUserByUsername(username: String, currencyCode: String, completion: @escaping UserClosure) {
        service.GET(path: Constants.getByUsername + "\(username)", data: mapper.currencyCodeParams(code: currencyCode)) { (result) in
            self.handleUserResponse(result: result, completion: completion)
        }
    }
    
    func followUser(user: User, completion: @escaping VoidClosure) {
        service.POST(path: Constants.follow, data: mapper.IDDictionary(user: user)) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func logout(completion: @escaping VoidClosure) {
        service.POST(path: Constants.logout, data: nil) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func unfollowUser(user: User, completion: @escaping VoidClosure) {
        service.POST(path: Constants.unfollow, data: mapper.IDDictionary(user: user)) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func getFollowing(user: User, completion: @escaping UsersClosure) {
        service.GET(path: Constants.followers + "\(user.id)", data: nil) { (result) in
            self.handleUsersResponse(result: result, completion: completion)
        }
    }
    
    func getFollowees(user: User, completion: @escaping UsersClosure) {
        service.GET(path: Constants.followees + "\(user.id)", data: nil) { (result) in
            self.handleUsersResponse(result: result, completion: completion)
        }
    }
    
    func getTestPush(completion: @escaping VoidClosure) {
        service.GET(path: Constants.testPushNotification, data: nil) { (result) in
            switch result {
            case .success:
                completion(.success(()))
                
            case .error:
                completion(.error(nil))
            }
        }
    }
    
    func registerUser(name: String, currency: Currency, FCMToken: String?, photo: UIImage, categories: [Category], expertise: Category, progress: ProgressClosure?, completion: @escaping UserClosure) {
        let params = mapper.createUserDict(name: name, currency: currency, token: FCMToken, categories: categories, expertise: expertise)
        
        service.multipartFormUpload(path: Constants.create, photo: photo, params: params, progress: progress) { response in
            self.handleUserResponse(result: response, completion: completion)
        }
    }
    
    func updateUser(user: User, photo: UIImage?, completion: @escaping UserClosure) {
        let params = mapper.updateUserDict(user: user)
        service.multipartFormUpload(path: Constants.update, photo: photo, params: params, progress: nil) { response in
            self.handleUserResponse(result: response, completion: completion)
        }
    }
    
    func updateUserPreferences(user: User, completion: @escaping UserClosure) {
        service.POST(path: Constants.updateUserPreferences, data: mapper.updateUserDict(user: user)) { (result) in
            self.handleUserResponse(result: result, completion: completion)
        }
    }
    
    
    func deleteUser(completion: @escaping VoidClosure) {
        service.DELETE(path: Constants.deleteUser, data: nil) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error:
                completion(.error(nil))
            }
        }
    }
    
    // MARK: Private methods
    
    private func handleUserResponse(result: Result<[String: Any]>, completion: @escaping UserClosure) {
        switch result {
        case .error(let error):
            completion(.error(error))
            
        case .success(let dict):
            guard let user = mapper.mapUserFromAuthResponse(dict: dict) else {
                completion(.error(nil))
                return
            }
            
            completion(.success(user))
        }
    }
    
    private func handleUsersResponse(result: Result<[String: Any]>, completion: @escaping UsersClosure) {
        switch result {
        case .error(let error):
            completion(.error(error))
            
        case .success(let dict):
            guard let users = mapper.mapUserFromUsersArray(dict: dict) else {
                completion(.error(nil))
                return
            }
            
            completion(.success(users))
        }
    }
}

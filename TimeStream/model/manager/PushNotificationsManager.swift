//
//  PushNotificationsManager.swift
//  TimeStream
//
//  Created by appssemble on 20.08.2021.
//

import Foundation
import Foundation
import FirebaseMessaging
import Firebase



class PushNotificationsManager: NSObject, MessagingDelegate {
    
    private struct Constants {
        struct Request {
            static let title = "Request"
            static let message = "There is a new reply to your request, tap to check it out!"
        }
    }
    
    var pushNotificationsToken: String? {
        let token = Messaging.messaging().fcmToken
        
        return token
    }
    
    
    static let instance = PushNotificationsManager()
    
    private override init() {
        super.init()
        
    }
    
    // MARK: Functions
    
    func initDelegate() {
        Messaging.messaging().delegate = self
    }
    
    // MARK: Token

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Do nothing
    }
    
    func getToken(completion: @escaping (_ token: String?) -> Void) {
        
        let token = Messaging.messaging().fcmToken
        completion(token)
    }
    
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        if let payloadJSONStr = userInfo["payload"] as? String {
            if let dict = String.convertToDictionary(text: payloadJSONStr) {
                print("DLD1: \(dict)")
            }
            
        } else if let dict = userInfo as? [String: Any] {
            print("DLD2: \(dict)")
        }
    }
}

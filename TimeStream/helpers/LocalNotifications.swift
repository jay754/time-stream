//
//  LocalNotificationHelper.swift
//  TimeStream
//
//  Created by appssemble on 05.08.2021.
//

import Foundation

enum LocalNotificationsTypes: String {
    case pausePlayingVideo
    
    case userChanged
    case videoUploaded
    
    case willMoveToExplorePage
}

struct LocalNotifications {

    static func addObserver(item: Any, selector: Selector, type: LocalNotificationsTypes) {
        NotificationCenter.default.addObserver(item, selector: selector, name:  NSNotification.Name(rawValue: type.rawValue), object: nil)
    }
    
    static func issueNotification(type: LocalNotificationsTypes) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: type.rawValue), object: nil)
    }
}

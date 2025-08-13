//
//  NSError+Extension.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import Foundation

struct ErrorConstants {
    static let TimeDomain = "TimeStream"
    
    static let InvalidRequest = -9998
    static let messages = "messages"
}

extension NSError {
    
    static var invalidResponse: Error {
        return NSError(domain: ErrorConstants.TimeDomain, code: ErrorConstants.InvalidRequest, userInfo: [ErrorConstants.messages: ["Invalid response"]])
    }
    
}

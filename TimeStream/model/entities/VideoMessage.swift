//
//  VideoMessage.swift
//  TimeStream
//
//  Created by appssemble on 04.11.2021.
//

import Foundation

enum VideoMessageType: String {
    case interact
    case response
    case declined
}

struct VideoMessage {
    let id: Int
    let userID: Int
    let videoPath: URL
    let thumbnailPath: URL
    let conversationID: Int
    let createdAt: Date
    let type: VideoMessageType
    let seen: Bool
    let postedVideoID: Int?
    let responseVideoMessageID: Int?
}

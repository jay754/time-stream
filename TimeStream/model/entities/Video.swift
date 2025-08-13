//
//  Video.swift
//  TimeStream
//
//  Created by appssemble on 08.10.2021.
//

import Foundation

struct Video {
    let id: Int
    let url: URL
    let description: String
    let thumbnailURL: URL
    let createdAt: Date
    let postedBy: User
    let tags: [String]
    let likes: Int
    let views: Int
    let likedByCurrentUser: Bool
    let privateVideo: Bool
    let category: Category
    
    var numberOfViews: String {
        switch views {
        case ..<1_000:
            return "\(views)"
        case 1_000 ..< 999_999:
            return "\(Int(views / 1_000))K"
        default:
            return "\(Int(views / 1_000_000))K"
        }
    }
}

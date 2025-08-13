//
//  ExploreActionsDelegate.swift
//  TimeStream
//
//  Created  on 23.12.2021.
//

import Foundation


protocol ExploreActionsDelegate: AnyObject {
    
    func exploreActionGoToUser(user: User)
    func exploreActionFollowUser(user: User)
    func exploreActionUnfollowUser(user: User)
    func exploreActionGoToVideoDetails(video: Video)
    func exploreActionGoToCategory(category: Category)
    
}

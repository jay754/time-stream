//
//  HomeMapper.swift
//  TimeStream
//
//  Created by appssemble on 04.01.2022.
//

import Foundation

class HomeMapper {
    
    private struct Constants {
        static let categories = "categories"
        static let videos = "videos"
        
        static let user = "user"
        static let groups = "groups"
    }

    private let videosMapper = VideoMapper()
    private let exploreMapper = ExploreServiceMapper()
    private let userMapper = UserMapper()
    
    // MARK: Methods
    
    func mapHomeVideoExploreResponse(dict: [String: Any]) -> HomeExplore? {
        guard let categoriesList = dict[Constants.categories] as? [String],
              let videos = videosMapper.mapVideosList(dict: dict) else {
                  return nil
              }
        
        let categories = categoriesList.compactMap({Category(rawValue: $0)})
        return HomeExplore(categories: categories, videos: videos)
    }
    
    func mapHomeVideoGroupsResponse(dict: [String: Any]) -> [HomeVideoGroup]? {
        guard let groupsArrayDict = dict[Constants.groups] as? [[String: Any]] else {
            return nil
        }
        
        var returnValues = [HomeVideoGroup]()
        
        for dict in groupsArrayDict {
            if let item = mapVideoGroup(dict: dict) {
                returnValues.append(item)
            }
        }
        
        return returnValues
    }
    
    // MARK: Private methods
    
    private func mapVideoGroup(dict: [String: Any]) -> HomeVideoGroup? {
        guard let userDict = dict[Constants.user] as? [String: Any],
              let user = userMapper.mapUser(dict: userDict),
              let videos = videosMapper.mapVideosList(dict: dict) else {
                  
                  return nil
              }
        
        return HomeVideoGroup(user: user, videos: videos)
    }
}

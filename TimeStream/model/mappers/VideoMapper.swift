//
//  VideoMapper.swift
//  TimeStream
//
//  Created by appssemble on 08.10.2021.
//

import Foundation

class VideoMapper {
    
    private struct Constants {
        static let id = "id"
        static let url = "url"
        static let description = "description"
        static let thumbnailURL = "thumbnail_url"
        static let createdAt = "created_at"
        static let postedBy = "posted_by"
        static let tags = "tags"
        static let likes = "likes"
        static let views = "views"
        static let likedByCurrentUser = "liked_by_current_user"
        
        static let videos = "videos"
        static let video = "video"
        
        static let videoPath = "video_path"
        static let thumbnailPath = "thumbnail_path"
        static let privateVideo = "private"
        
        static let category = "category"
    }
    
    private let userMapper = UserMapper()
    
    // MARK: Methods
    
    func createDictionary(video: Video, videoURL: PresignedUpload, thumbnail: PresignedUpload) -> [String: Any] {
        return [Constants.videoPath: videoURL.path,
                Constants.thumbnailPath: thumbnail.path,
                Constants.description: video.description,
                Constants.privateVideo: video.privateVideo,
                Constants.category: video.category.rawValue,
                Constants.tags: video.tags]
    }
    
    func createDictionary2(video: Video) -> [String: Any] {
        return [Constants.videoPath: "videoURL.path",
                Constants.thumbnailPath: "thumbnail.path",
                Constants.description: video.description,
                Constants.privateVideo: video.privateVideo,
                Constants.category: video.category.rawValue,
                Constants.tags: video.tags]
    }
    
    func mapVideoResponse(dict: [String: Any]) -> Video? {
        guard let dict = dict[Constants.video] as? [String: Any] else {
            return nil
        }
        
        return mapVideo(dict: dict)
    }
    
    func mapVideosList(dict: [String: Any]) -> [Video]? {
        guard let array = dict[Constants.videos] as? [[String: Any]] else {
            return nil
        }
        
        var videos = [Video]()
        for dict in array {
            if let video = mapVideo(dict: dict) {
                videos.append(video)
            }
        }
        
        return videos
    }
    
    func mapVideo(dict: [String: Any]) -> Video? {
        guard let id = dict[Constants.id] as? Int,
              let urlStr = dict[Constants.url] as? String,
              let url = URL(string: urlStr),
              let description = dict[Constants.description] as? String,
              let thumbnailStr = dict[Constants.thumbnailURL] as? String,
              let thumbnail = URL(string: thumbnailStr),
              let createdAtString = dict[Constants.createdAt] as? String,
              let createdAt = Date.dateFromBackend(string: createdAtString),
              let postedByDict = dict[Constants.postedBy] as? [String: Any],
              let postedBy = userMapper.mapUser(dict: postedByDict),
              let tags = dict[Constants.tags] as? [String],
              let likes = dict[Constants.likes] as? Int,
              let views = dict[Constants.views] as? Int,
              let privateVideo = dict[Constants.privateVideo] as? Bool,
              let categoryRaw = dict[Constants.category] as? String,
              let category = Category(rawValue: categoryRaw),
              let likedByCurrentUser = dict[Constants.likedByCurrentUser] as? Bool else {
                  
                  return nil
              }
        
        return Video(id: id, url: url, description: description, thumbnailURL: thumbnail, createdAt: createdAt, postedBy: postedBy, tags: tags.reversed(), likes: likes, views: views, likedByCurrentUser: likedByCurrentUser, privateVideo: privateVideo, category: category)
    }
    
    // MARK: Private methods
    
   
}

//
//  VideoService.swift
//  TimeStream
//
//  Created by appssemble on 08.10.2021.
//

import UIKit

typealias VideosClosure = (_ result: Result<[Video]>) -> Void
typealias VideoClosure = (_ result: Result<Video>) -> Void

class VideoService {
    
    private struct Constants {
        static let videos = "videos/"
        
        
        static let create = videos + "create"
        static let currentUser = videos + "current_user"
        static let otherUser = videos + "other_user/"
        static let addLike = "add_like"
        static let like = "like"
        static let addView = "add_view"
        static let relatedVideos = "related_videos"
    }
    
    private let service = ServiceHelper()
    private let userMapper = UserMapper()
    private let videoMapper = VideoMapper()
    
    // MARK: Methods
    
//    func create(video: Video, videoURL: PresignedUpload, thumbnailURL: PresignedUpload, completion: @escaping VideoClosure) {
//        let path = Constants.create
//        let data = videoMapper.createDictionary(video: video, videoURL: videoURL, thumbnail: thumbnailURL)
//        
//        service.POST(path: path, data: data) { result in
//            self.handleVideoResponse(response: result, completion: completion)
//        }
//    }
//    
    func create(video: Video, videoURL: URL, thumbnail: UIImage, progress: ProgressClosure?, completion: @escaping VideoClosure) {
        let path = Constants.create
        let data = videoMapper.createDictionary2(video: video)
        
        service.multipartFormUpload(path: path, video: videoURL, thumbnail: thumbnail, params: data, progress: progress)  { result in
            self.handleVideoResponse(response: result, completion: completion)
        }
    }
    
    func addView(videoID: Int, completion: @escaping VideoClosure) {
        let path = Constants.videos + "\(videoID)/" + Constants.addView
        
        service.POST(path: path, data: nil) { result in
            self.handleVideoResponse(response: result, completion: completion)
        }
    }
    
    func addLike(videoID: Int, completion: @escaping VideoClosure) {
        let path = Constants.videos + "\(videoID)/" + Constants.addLike
        
        service.POST(path: path, data: nil) { result in
            self.handleVideoResponse(response: result, completion: completion)
        }
    }
    
    func deleteLike(videoID: Int, completion: @escaping VideoClosure) {
        let path = Constants.videos + "\(videoID)/" + Constants.like
        
        service.DELETE(path: path, data: nil) { result in
            self.handleVideoResponse(response: result, completion: completion)
        }
    }
    
    func getVideo(videoID: Int, completion: @escaping VideoClosure) {
        let path = Constants.videos + "\(videoID)/"
        
        service.GET(path: path, data: nil) { result in
            self.handleVideoResponse(response: result, completion: completion)
        }
    }
    
    func currentUserVideos(completion: @escaping VideosClosure) {
        service.GET(path: Constants.currentUser, data: nil) { result in
            self.handleVideosResponse(response: result, completion: completion)
        }
    }
    
    func getRelatedVideos(videoID: Int, currencyCode: String, completion: @escaping VideosClosure) {
        let path = Constants.videos + "\(videoID)/" + Constants.relatedVideos
        service.GET(path: path, data: userMapper.currencyCodeParams(code: currencyCode)) { result in
            self.handleVideosResponse(response: result, completion: completion)
        }
    }
    
    func otherUserVideos(userID: Int, currencyCode: String, completion: @escaping VideosClosure) {
        let path = Constants.otherUser + "\(userID)"
        
        service.GET(path: path, data: userMapper.currencyCodeParams(code: currencyCode)) { result in
            self.handleVideosResponse(response: result, completion: completion)
        }
    }
    
    func deleteVideo(video: Video, completion: @escaping VoidClosure) {
        let path = Constants.videos + "\(video.id)/"
        
        service.DELETE(path: path, data: nil) { response in
            switch response {
            case .success:
                completion(.success(()))
                
            case .error(let error):
                completion(.error(error))
            }
        }
    }
    
    // MARK: Private method
    
    private func handleVideoResponse(response: Result<[String: Any]>, completion: @escaping VideoClosure) {
        switch response {
        case .error(let error):
            completion(.error(error))
            
        case .success(let dict):
            guard let video = self.videoMapper.mapVideoResponse(dict: dict) else {
                completion(.error(nil))
                return
            }
            
            completion(.success(video))
        }
    }
    
    private func handleVideosResponse(response: Result<[String: Any]>, completion: @escaping VideosClosure) {
        switch response {
        case .error(let error):
            completion(.error(error))
            
        case .success(let dict):
            if let videos = self.videoMapper.mapVideosList(dict: dict) {
                completion(.success(videos))
            } else {
                completion(.error(nil))
            }
        }
    }
    
    private func presignedURL(path: String, completion: @escaping URLClosure) {
        service.GET(path: path, data: nil) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let url = self.userMapper.mapURLFromResponse(dict: dict) else {
                    completion(.error(nil))
                    
                    return
                }
                
                completion(.success(url))
            }
        }
    }
}

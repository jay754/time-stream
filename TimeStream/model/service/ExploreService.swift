//
//  ExploreService.swift
//  TimeStream
//
//  Created on 20.12.2021.
//

import Foundation
import Alamofire

typealias VideosInCategoriesClosure = (_ result: Result<[Category: [Video]]>) -> Void

class ExploreService {
    
    private struct Constants {
        static let explore = "explore/"
        
        static let creators = "creators"
        static let videos = "videos"
        
        static let searchContent = explore + "search_content"
        static let searchPeople = explore + "search_people"
        static let searchTags = explore + "search_tags"
        
        static let newestPeople = explore + "newest_people"
        static let newestVideos = explore + "newest_videos"
        static let newestTags = explore + "newest_tags"
    }
    
    private let service = ServiceHelper()
    private let exploreMapper = ExploreServiceMapper()
    private let userMapper = UserMapper()
    private let videoMapper = VideoMapper()
    
    private var newestPeopleRequest: DataRequest?
    private var newestVideosRequest: DataRequest?
    private var newestTagsVideosRequest: DataRequest?
    private var searchContentRequest: DataRequest?
    private var searchPeopleRequest: DataRequest?
    private var searchTagsRequest: DataRequest?
    
    // MARK: Methods
    
    func popularVideos(category: Category, page: Int, completion: @escaping VideosClosure) {
        let path = Constants.explore + category.rawValue + "/" + Constants.videos
        
        service.GET(path: path, data: exploreMapper.pageParam(page: page)) { result in
            self.handleVideosResponse(response: result, completion: completion)
        }
    }
    
    func popularCreators(category: Category, completion: @escaping UsersClosure) {
        let path = Constants.explore + category.rawValue + "/" + Constants.creators
        
        service.GET(path: path, data: nil) { result in
            self.handleUsersResponse(response: result, completion: completion)
        }
    }
    
    func popularVideos(categories: [Category], completion: @escaping VideosInCategoriesClosure) {
        let path = Constants.explore + Constants.videos
        
        service.POST(path: path, data: exploreMapper.categories(categories: categories)) { result in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                if let videos = self.exploreMapper.videosFromCategories(dict: dict) {
                    completion(.success(videos))
                } else {
                    completion(.error(nil))
                }
            }
        }
    }
    
    func popularCreators(categories: [Category], completion: @escaping UsersClosure) {
        let path = Constants.explore + Constants.creators
        let params = exploreMapper.categories(categories: categories)
        
        service.POST(path: path, data: params) { result in
            self.handleUsersResponse(response: result, completion: completion)
        }
    }
    
    func searchContent(term: String, page: Int, completion: @escaping VideosClosure) {
        let params = exploreMapper.search(term: term, page: page)
        
        searchContentRequest?.cancel()
        searchContentRequest = service.GET(path: Constants.searchContent, data: params) { response in
            self.handleVideosResponse(response: response, completion: completion)
        }
    }
    
    func searchPeople(term: String, page: Int, completion: @escaping UsersClosure) {
        let params = exploreMapper.search(term: term, page: page)
        
        searchPeopleRequest?.cancel()
        searchPeopleRequest = service.GET(path: Constants.searchPeople, data: params) { response in
            self.handleUsersResponse(response: response, completion: completion)
        }
    }
    
    func searchTags(term: String, page: Int, completion: @escaping VideosClosure) {
        let params = exploreMapper.search(term: term, page: page)
        
        searchTagsRequest?.cancel()
        searchTagsRequest = service.GET(path: Constants.searchTags, data: params) { response in
            self.handleVideosResponse(response: response, completion: completion)
        }
    }
    
    func newestPeople(page: Int, completion: @escaping UsersClosure) {
        let params = exploreMapper.pageParam(page: page)
        
        newestPeopleRequest?.cancel()
        newestPeopleRequest = service.GET(path: Constants.newestPeople, data: params) { response in
            self.handleUsersResponse(response: response, completion: completion)
        }
    }
    
    func newestVideos(page: Int, completion: @escaping VideosClosure) {
        let params = exploreMapper.pageParam(page: page)
        
        newestVideosRequest?.cancel()
        newestVideosRequest = service.GET(path: Constants.newestVideos, data: params) { response in
            self.handleVideosResponse(response: response, completion: completion)
        }
    }
    
    func newestVideosFromTags(page: Int, completion: @escaping VideosClosure) {
        let params = exploreMapper.pageParam(page: page)
        
        newestTagsVideosRequest?.cancel()
        newestTagsVideosRequest = service.GET(path: Constants.newestTags, data: params) { response in
            self.handleVideosResponse(response: response, completion: completion)
        }
    }
    
    // MARK: Private method
    
    private func handleUsersResponse(response: Result<[String: Any]>, completion: @escaping UsersClosure) {
        switch response {
        case .error(let error):
            completion(.error(error))
            
        case .success(let dict):
            if let users = self.userMapper.mapUserFromUsersArray(dict: dict) {
                completion(.success(users))
            } else {
                completion(.error(nil))
            }
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
}

//
//  HomeService.swift
//  TimeStream
//
//  Created n 04.01.2022.
//

import Foundation

typealias HomeExploreClosure = (_ result: Result<HomeExplore>) -> Void
typealias HomeVideosClosure = (_ result: Result<[HomeVideoGroup]>) -> Void

class HomeService {
    
    private struct Constants {
        static let home = "home/"
        
        static let exploreVideos = home + "explore_videos"
        static let videos = home + "videos"
    }
    
    private let service = ServiceHelper()
    private let mapper = HomeMapper()
    
    // MARK: Methods
    
    func exploreVideos(completion: @escaping HomeExploreClosure) {
        service.GET(path: Constants.exploreVideos, data: nil) { result in
            switch result {
            case .error:
                completion(.error(nil))
                
            case .success(let dict):
                if let value = self.mapper.mapHomeVideoExploreResponse(dict: dict) {
                    completion(.success(value))
                    return
                }
                
                completion(.error(nil))
            }
        }
    }
    
    func homeVideos(completion: @escaping HomeVideosClosure) {
        service.GET(path: Constants.videos, data: nil) { result in
            switch result {
            case .error:
                completion(.error(nil))
                
            case .success(let dict):
                if let value = self.mapper.mapHomeVideoGroupsResponse(dict: dict) {
                    completion(.success(value))
                    return
                }
                
                completion(.error(nil))
            }
        }
    }
    
    
}

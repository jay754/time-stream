//
//  ExploreMapper.swift
//  TimeStream
//
//  
//

import Foundation

class ExploreServiceMapper {
    
    private struct Constants {
        static let page = "page"
        static let categories = "categories"
        
        static let category = "category"
        static let videos = "videos"
        
        static let term = "term"
    }

    private let videosMapper = VideoMapper()
    
    // MARK: Methods
    
    func pageParam(page: Int) -> [String: Any] {
        return [Constants.page: page]
    }
    
    func categories(categories: [Category]) -> [String: Any] {
        return [Constants.categories: categories.map{$0.rawValue}]
    }
    
    func search(term: String, page: Int) -> [String: Any] {
        return [Constants.term: term,
                Constants.page: page]
    }
    
    func videosFromCategories(dict: [String: Any]) -> [Category: [Video]]? {
        guard let array = dict[Constants.videos] as? [[String: Any]] else {
            return nil
        }
        
        var returnData = [Category: [Video]]()
        
        for dict in array {
            guard let categoryRaw = dict[Constants.category] as? String,
                  let categ = Category(rawValue: categoryRaw),
                  let videos = videosMapper.mapVideosList(dict: dict) else {
                      
                      continue
                  }
            
            returnData[categ] = videos
        }
        
        return returnData
    }
}

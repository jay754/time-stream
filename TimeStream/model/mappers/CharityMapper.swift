//
//  CharityMapper.swift
//  TimeStream
//
//  Created by appssemble on 18.08.2021.
//

import Foundation

class CharityMapper {
    
    private struct Constants {
        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let webpage = "webpage"
        static let photoURL = "picture_url"
        
        static let charities = "charities"
    }
    
    func mapFromList(result: [String: Any]) -> [Charity] {
        guard let array = result[Constants.charities] as? [[String: Any]] else {
            return [Charity]()
        }
        
        var charities = [Charity]()
        for dict in array {
            if let charity = mapCharity(dict: dict) {
                charities.append(charity)
            }
        }
        
        return charities
    }

    func mapCharity(dict: [String: Any]) -> Charity? {
        guard let id = dict[Constants.id] as? Int,
              let name = dict[Constants.name] as? String,
              let description = dict[Constants.description] as? String,
        let photo = dict[Constants.photoURL] as? String,
        let url = URL(string: photo) else {
            
            return nil
        }
        
        var web: URL?
        if let webLink = dict[Constants.webpage] as? String,
           let webURL = URL(string: webLink) {
            web = webURL
        }
        
        return Charity(id: id, imageURL: url, title: name, subtitle: description, webpage: web)
    }
}

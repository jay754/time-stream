//
//  Category.swift
//  TimeStream
//
//  Created by appssemble on 07.12.2021.
//

import Foundation


enum Category: String {
    
    case forYou
    
    case ai
    case animals
    case art
    case beauty
    case books
    case business
    case careers
    case charity
    case coaching
    case diy
    case education
    case entertainment
    case environment
    case fashion
    case food
    case funny
    case gaming
    case howTo = "how_to"
    case humanities
    case inspiration
    case lifestyle
    case music
    case nfts_crypto
    case other
    case photography
    case reviews
    case science
    case sports
    case tech
    case travel
    case video
    case web3
    case wellbeing


    // MARK: Helpers
    
    static var allCategories: [Category] {
        return [.ai, .animals, .art, .beauty, .books, .business, .careers, .charity, .coaching, .diy, .education, .entertainment, . environment, .fashion, .food, .funny, .gaming, .howTo, .humanities, .inspiration, .lifestyle, .music, .nfts_crypto, .other, .photography, .reviews, .science, .sports, .tech, .travel, .video, .web3, .wellbeing]
    }
    
    static var allCategoriesWithForYourItem: [Category] {
        return [.forYou] + allCategories
    }
    
    var name: String {
        get {
            switch self {
            case .diy:
                return "DIY"
                
            case .forYou:
                return "For you"

            case .ai:
                return "AI"
                
            case .howTo:
                return "How to"
                
            case .nfts_crypto:
                return "NFTs"
        
            default:
                return rawValue.capitalized
            }
        }
    }
}

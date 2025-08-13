//
//  CharityService.swift
//  TimeStream
//
//  Created by appssemble on 18.08.2021.
//

import Foundation

typealias CharitiesClosure = (_ result: Result<[Charity]>) -> Void

class CharityService {
    private struct Constants {
        static let charities = "charities/"
        
        static let getCharities = charities + "get_charities"
    }
    
    private let service = ServiceHelper()
    private let mapper = CharityMapper()
    
    // MARK: Methods
    
    func getCharities(completion: @escaping CharitiesClosure) {
        service.GET(path: Constants.getCharities, data: nil) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                let charities = self.mapper.mapFromList(result: dict)
                completion(.success(charities))
            }
        }
    }
}

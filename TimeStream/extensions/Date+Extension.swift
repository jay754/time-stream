//
//  Date+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 07.06.2021.
//

import Foundation

extension Date {
    
    static func dateFromBackend(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from:string)
    }
    
}

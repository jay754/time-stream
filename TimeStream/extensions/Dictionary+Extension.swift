//
//  Dictionary+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 28.05.2021.
//

import Foundation

extension Dictionary {

    func toJSON() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self)
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        } catch {}
       
        return nil
    }
}

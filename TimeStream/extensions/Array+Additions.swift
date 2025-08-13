//
//  Array+Additions.swift
//  Places
//
//  Created by appssemble on 02/04/2020.
//  Copyright © 2020 Appssemble. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}

extension Array {

    mutating func removeExtraItems(pageSize: Int) {
        let count = self.count
        let extraItems = Int(count % pageSize)
        
        removeLast(extraItems)
    }
}

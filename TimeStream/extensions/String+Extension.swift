//
//  String+Extension.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import Foundation

extension String {

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var containsNumbers: Bool {
        let numberRegEx  = ".*[0-9]+.*"
        let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        
        return testCase.evaluate(with: self)
    }
    
    var isAlphanumericWithSpaces: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9 ]", options: .regularExpression) == nil
    }
    
    var hasLeadingOrTrailingSpaces: Bool {
        if hasPrefix(" ") || hasSuffix(" ") {
            return true
        }
        
        return false
    }
    
    var isAlphanumericWithSpacesAndDash: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9- ]", options: .regularExpression) == nil
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
            
            return ranges
        }
        
        return ranges
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }

    static func convertToDictionary(text: String) -> [String: Any]? {
         if let data = text.data(using: .utf8) {
             do {
                 return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
             } catch {
                 print(error.localizedDescription)
             }
         }
     
         return nil
     }
    
    func limit(length: Int) -> String {
        if self.count > length {
            let endIndex = self.index(self.startIndex, offsetBy: length - 3)
            return String(self[..<endIndex]) + "..."
        } else {
            return self
        }
    }
}

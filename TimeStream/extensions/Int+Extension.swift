//
//  Int+Extension.swift
//  OneSave
//
//  Created by appssemble on 05.03.2021.
//

import Foundation

extension Int {
    
    func formattedString() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        
        return formatter.string(for: self)!
    }
    
    func priceFromCents() -> String {
        return "\(Int(self / 100))"
    }
    
    func priceFromCentsInt() -> Int {
        return Int(self / 100)
    }
    
    func priceFromCentsDouble() -> Double {
        return Double(self) / 100.0
    }
    
    func centsPrice() -> Int {
        return self * 100
    }
    
    func secondsToTime() -> String {
        
        let (h,m,s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
        
        let h_string = h < 10 ? "\(h)" : "\(h)"
        let m_string =  m < 10 ? "\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        if h_string != "0" {
            return "\(h_string):\(m_string):\(s_string)"
        }
        
        return "\(m_string):\(s_string)"
    }
    
    func formattedPrice(currency: Currency) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = currency.locale()
        currencyFormatter.generatesDecimalNumbers = false
        currencyFormatter.maximumFractionDigits = 0
        
        let value = self.priceFromCentsInt()
        
        if let formatted = currencyFormatter.string(from: NSNumber(integerLiteral: value)) {
            return formatted
        }
        
        return "\(value)" + " \(currency.sign())"
    }
    
    func formattedPriceDecimals(currency: Currency) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = currency.locale()
        currencyFormatter.generatesDecimalNumbers = true
        currencyFormatter.maximumFractionDigits = 2
        
        let value = priceFromCentsDouble()
        
        if let formatted = currencyFormatter.string(from: NSNumber(floatLiteral: value)) {
            return formatted
        }
        
        return "\(value)" + " \(currency.sign())"
    }
}

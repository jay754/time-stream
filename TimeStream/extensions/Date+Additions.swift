//
//  Date+Extension.swift
//  Places
//
//  Created by appssemble on 24/03/2020.
//  Copyright © 2020 Appssemble. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    func prettyFormatted() -> String {
        var formattedDate = self.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current)
        
        if formattedDate == "last week" {
            formattedDate = "1 week ago"
        }
        
        if formattedDate == "yesterday" {
            formattedDate = "1 day ago"
        }
        
        if formattedDate == "last month" {
            formattedDate = "1 month ago"
        }
        
        if formattedDate == "last year" {
            formattedDate = "1 year ago"
        }
        
        return formattedDate
    }
    
    func prettyFormattedSmall() -> String {
        var formattedDate = self.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locale.current)
        
        if formattedDate == "last week" {
            formattedDate = "1 week ago"
        }
        
        if formattedDate == "yesterday" {
            formattedDate = "1 day ago"
        }
        
        if formattedDate == "last month" {
            formattedDate = "1 month ago"
        }
        
        if formattedDate == "last year" {
            formattedDate = "1 year ago"
        }
        
        return formattedDate.replacingOccurrences(of: " ago", with: "")
    }
    
    func formatted() -> String {
        return self.toFormat("dd MMM yyyy")
    }
    
    func shortFormat() -> String {
        return self.toFormat("dd/MM")
    }
    
    func dayMonthFormat() -> String {
        return self.toFormat("dd MMM")
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var previousMonth: Date {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        return previousMonth
    }
    
    var startOfMonth: Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return (interval?.start.toLocalTime())! // Without toLocalTime it give last months last date
    }
    
    var endOfMonth: Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return interval!.end
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone    = TimeZone.current
        let seconds     = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var year: String {
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        
        return format.string(from: self)
    }
    
    static func defaultDailyNotification() -> Date {
        let date = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!
        
        return date
    }
    
}




//
//  Report.swift
//  TimeStream
//
//  Created by appssemble on 03.11.2021.
//

import Foundation

enum ReportReason {
    case reason1
    case reason2
    case reason3
    case reason4
    case reason5
    case reason6
    case reason7
    case reason8
    case reason9
    case reason10
    
    
    // MARK: Methods
    
    func reasonAsText() -> String {
        switch self {
        case .reason1:
            return "reason.1".localized
            
        case .reason2:
            return "reason.2".localized
            
        case .reason3:
            return "reason.3".localized
            
        case .reason4:
            return "reason.4".localized
            
        case .reason5:
            return "reason.5".localized
            
        case .reason6:
            return "reason.6".localized
            
        case .reason7:
            return "reason.7".localized
            
        case .reason8:
            return "reason.8".localized
            
        case .reason9:
            return "reason.9".localized
            
        case .reason10:
            return "reason.10".localized
        }
    }
}

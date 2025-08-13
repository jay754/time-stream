//
//  ReportMapper.swift
//  TimeStream
//
//  Created by appssemble on 03.11.2021.
//

import Foundation

class ReportMapper {
    
    private struct Constants {
        static let id = "id"
        static let reason = "reason"
    }
    
    // MARK: Methods
    
    func mapReportToParams(id: Int, reason: ReportReason) -> [String: Any] {
        return [Constants.id: id,
                Constants.reason: reason.reasonAsText()]
    }
    
}

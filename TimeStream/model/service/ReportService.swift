//
//  ReportService.swift
//  TimeStream
//
//  Created by appssemble on 03.11.2021.
//

import Foundation


class ReportService {
    
    private struct Constants {
        static let reports = "reports/"
        
        static let video = reports + "report_video"
        static let videoMessage = reports + "report_video_message"
        static let user = reports + "report_user"
    }
    
    private let service = ServiceHelper()
    private let mapper = ReportMapper()
    
    // MARK: Methods

    func reportUser(userID: Int, reason: ReportReason, completion: @escaping VoidClosure) {
        let params = mapper.mapReportToParams(id: userID, reason: reason)
        
        service.POST(path: Constants.user, data: params) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func reportVideo(videoID: Int, reason: ReportReason, completion: @escaping VoidClosure) {
        let params = mapper.mapReportToParams(id: videoID, reason: reason)
        
        service.POST(path: Constants.video, data: params) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
    
    func reportVideoMessage(videoMessageID: Int, reason: ReportReason, completion: @escaping VoidClosure) {
        let params = mapper.mapReportToParams(id: videoMessageID, reason: reason)
        
        service.POST(path: Constants.videoMessage, data: params) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

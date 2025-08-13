//
//  ReportHelper.swift
//  TimeStream
//
//  Created by appssemble on 03.11.2021.
//

import Foundation
import UIKit

class ReportHelper {
    
    private let service = ReportService()
    private let reasons: [ReportReason] = [.reason1, .reason2, .reason3, .reason4, .reason5, .reason6, .reason7, .reason8, .reason9, .reason10]
    

    // MARK: Methods
    
    func reportVideo(videoID: Int, from: BaseViewController) {
        let alert = UIAlertController(title: "report".localized, message: "report.reasons.video".localized, preferredStyle: .actionSheet)

        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason.reasonAsText(), style: .default, handler:{ (UIAlertAction) in
                self.addVideoReport(videoID: videoID, reason: reason, vc: from)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
        }))

        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = from.view

        from.present(alert, animated: true, completion: {
        })
    }
    
    func reportConversationVideo(videoMessageID: Int, from: BaseViewController) {
        let alert = UIAlertController(title: "report".localized, message: "report.reasons.video".localized, preferredStyle: .actionSheet)

        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason.reasonAsText(), style: .default, handler:{ (UIAlertAction) in
                self.addVideoMessageReport(videoMessageID: videoMessageID, reason: reason, vc: from)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
        }))

        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = from.view

        from.present(alert, animated: true, completion: {
        })
    }
    
    func reportUser(userID: Int, from: BaseViewController) {
        let alert = UIAlertController(title: "report".localized, message: "report.reasons.user".localized, preferredStyle: .actionSheet)

        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason.reasonAsText(), style: .default, handler:{ (UIAlertAction) in
                self.addUserReport(userID: userID, reason: reason, vc: from)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
        }))

        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = from.view

        from.present(alert, animated: true, completion: {
        })
    }
    
    // MARK: Private methods
    
    private func addVideoMessageReport(videoMessageID: Int, reason: ReportReason, vc: BaseViewController) {
        vc.loading = true
        service.reportVideoMessage(videoMessageID: videoMessageID, reason: reason) { result in
            // Do nothing
            vc.loading = false
            self.showSuccessMessage()
        }
    }
    
    private func addVideoReport(videoID: Int, reason: ReportReason, vc: BaseViewController) {
        vc.loading = true
        service.reportVideo(videoID: videoID, reason: reason) { result in
            // Do nothing
            vc.loading = false
            self.showSuccessMessage()
        }
    }
    
    private func addUserReport(userID: Int, reason: ReportReason, vc: BaseViewController) {
        vc.loading = true
        service.reportUser(userID: userID, reason: reason) { result in
            // Do nothing
            vc.loading = false
            self.showSuccessMessage()
        }
    }
    
    private func showSuccessMessage() {
        AlertHelper.displayMessageOnTopOfEverything("report.your.report.was.sent".localized, title: "report.thank.you".localized)
    }
    
}

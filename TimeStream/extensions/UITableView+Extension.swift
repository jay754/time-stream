//
//  UITableView+Extension.swift
//  Places
//
//  Created by appssemble on 18/12/2020.
//  Copyright © 2020 Appssemble. All rights reserved.
//

import UIKit
import KafkaRefresh

extension UITableView {
    
    func setMessage(_ message: String) {
        let padding: CGFloat = 24
        let width = self.bounds.size.width - (2 * padding)
        let lblMessage = UILabel(frame: CGRect(x: padding, y: 0, width: width, height: self.bounds.size.height))
        lblMessage.addWidthConstraint(value: width)
        lblMessage.text = message
        lblMessage.font = UIFont.defaultFontSemiBold(ofSize: 14)
        lblMessage.numberOfLines = 0
        lblMessage.alpha = 0.7
        lblMessage.textAlignment = .center
        lblMessage.sizeToFit()
        
        self.backgroundView = lblMessage
        
        lblMessage.centerInSuperview()
    }
    
    func setMessageExplore(_ message: String) {
        let padding: CGFloat = 24
        let width = self.bounds.size.width - (2 * padding)
        let lblMessage = UILabel(frame: CGRect(x: padding, y: 0, width: width, height: self.bounds.size.height))
        lblMessage.addWidthConstraint(value: width)
        lblMessage.text = message
        lblMessage.font = UIFont.defaultFontSemiBold(ofSize: 14)
        lblMessage.textColor = .secondaryText
        lblMessage.numberOfLines = 0
        lblMessage.alpha = 0.7
        lblMessage.textAlignment = .center
        lblMessage.sizeToFit()
        
        self.backgroundView = lblMessage
        
        lblMessage.centerInSuperview()
    }
    
    func clearBackground() {
        self.backgroundView = nil
    }
    
    func scrollToBottom(isAnimated: Bool = false){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
    
    func scrollToTop(isAnimated: Bool = false) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    
    func startAutoRefresh(refresh: @escaping EmptyClosure) {
        bindFootRefreshHandler({
            refresh()
            
        }, themeColor: UIColor.accent, refreshStyle: .replicatorCircle)
        
        footRefreshControl.autoRefreshOnFoot = true
    }
    
    func beginRefresh() {
        footRefreshControl.beginRefreshing()
    }
    
    func endCurrentRefresh() {
        footRefreshControl.endRefreshing()
    }
    
    func stopAllRefresh() {
        footRefreshControl.endRefreshing()
        footRefreshControl.autoRefreshOnFoot = false
    }
}

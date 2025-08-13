//
//  UICollectionView+Extension.swift
//  TimeStream
//
//  Created by appssemble on 11.10.2021.
//

import UIKit
import KafkaRefresh

extension UICollectionView {
    
    func setMessage(_ message: String) {
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
    
    func stopRefresh() {
        footRefreshControl.endRefreshing()
        footRefreshControl.autoRefreshOnFoot = false
    }
}

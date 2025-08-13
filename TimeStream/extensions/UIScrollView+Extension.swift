//
//  UIScrollView+Extension.swift
//  TimeStream
//
//  Created by appssemble on 04.01.2022.
//

import UIKit

extension UIScrollView {

    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool, inset: CGFloat = 16) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: childStartPoint.x - inset, y: childStartPoint.y - inset, width: self.frame.width - (2 * inset), height: self.frame.height), animated: animated)
        }
    }
}

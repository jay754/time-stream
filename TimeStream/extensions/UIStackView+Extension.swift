//
//  UIStackView+Extension.swift
//  TimeStream
//
//  Created by appssemble on 02.10.2021.
//

import UIKit

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        let subviews = arrangedSubviews
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }
}

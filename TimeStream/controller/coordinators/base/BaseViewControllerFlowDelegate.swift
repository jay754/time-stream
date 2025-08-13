//
//  BaseViewControllerFlowDelegate.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import Foundation
import UIKit

// Should be extended by the flow delegates

protocol BaseViewControllerFlowDelegate: class {
    func backButtonPressed(from viewController:UIViewController)
}

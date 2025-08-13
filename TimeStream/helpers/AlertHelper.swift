//
//  AlertHelper.swift
//  FlexiPass
//
//  Created by appssemble on 12.05.2021.
//

import UIKit

class AlertHelper {
    
    static func displayMessageOnTopOfEverything(_ message: String, title: String, completion: EmptyClosure? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
            
            completion?()
        }
        
        alertController.addAction(action)
        alertController.showOnANewWindow()
    }
}

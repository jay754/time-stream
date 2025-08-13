//
//  DisableInteractionsView.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit

protocol DisableInteractionViewProtocol: class {
    func disableInteractionsPressed()
}

class DisableInteractionsView: UIView {
    
    weak var delegate: DisableInteractionViewProtocol?
    
    // MARK: Actions
    
    @IBAction func disableInteractions(_ sender: Any) {
        delegate?.disableInteractionsPressed()
    }
}

//
//  EnableInteractionsView.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit

enum SelectedTopup: Int {
    case three = 3
    case six = 6
    case nine = 9
}

protocol EnableInteractionsViewProtocol: class {
    func enableInteractionsPressed(count: Int)
}


class EnableInteractionsView: UIView {
    
    weak var delegate: EnableInteractionsViewProtocol?
    
    @IBOutlet weak var enableInteractionsButton: ConfirmationButton!
    @IBOutlet var buttons: [UIButton]!
    
    private var selectedTopup: SelectedTopup = .three
    

    // MARK: Actions
    
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        selectedTopup = .three
        disableAllButtons()
        
        enable(button: sender)
    }
    
    @IBAction func secondButtonTapped(_ sender: UIButton) {
        selectedTopup = .six
        disableAllButtons()
        
        enable(button: sender)
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        selectedTopup = .nine
        disableAllButtons()
        
        enable(button: sender)
    }
    
    @IBAction func enableInteractions(_ sender: Any) {
        delegate?.enableInteractionsPressed(count: selectedTopup.rawValue)
    }
    
    // MARK: Private methods
    
    private func disableAllButtons() {
        for button in buttons {
            disable(button: button)
        }
    }
    
    private func disable(button: UIButton) {
        button.backgroundColor = UIColor.unselectedContainerColor
        button.setTitleColor(UIColor.unselectedContainerText, for: .normal)
    }
    
    private func enable(button: UIButton) {
        button.backgroundColor = UIColor.accent
        button.setTitleColor(UIColor.white, for: .normal)
    }
}

//
//  AddTipPopupViewController.swift
//  TimeStream
//
//  Created by appssemble on 16.08.2021.
//

import UIKit

protocol AddTipPopupViewControllerDelegate: class {
    func addTip(vc: AddTipPopupViewController, cents: Int)
}

class AddTipPopupViewController: UIViewController {

    @discardableResult static func displayFrom(vc: UIViewController, completion: EmptyClosure?, delegate: AddTipPopupViewControllerDelegate?) -> AddTipPopupViewController {
        let controller =
            AddTipPopupViewController(nibName: "AddTipPopupViewController", bundle: nil)
        
        controller.completion = completion
        controller.delegate = delegate
        controller.modalPresentationStyle = .overFullScreen
        vc.present(controller, animated: false, completion: nil)
        
        return controller
    }
    
    weak var delegate: AddTipPopupViewControllerDelegate?

    @IBOutlet weak var currencySymbolField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var sheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var visualView: UIVisualEffectView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var giveTipButton: ConfirmationButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    fileprivate var completion: EmptyClosure?
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        enableTipButtonIfNeeded()
        close(dismissVC: false, alpha: false)
        
        currencySymbolField.text = Currency.current().sign()
        
        amountField.addTextChangeObserver(item: self, selector: #selector(textFieldDidChange(_:)))
        
        descriptionLabel.text = String(format: "tip.details.text".localized, Currency.current().sign())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        open(alpha: true)
    }
    
    // MARK: Actions
    
    @IBAction func closeTapped(_ sender: Any) {
        close(dismissVC: true, alpha: true)
    }
    
    @IBAction func giveTip(_ sender: Any) {
        guard let text = amountField.text,
              let value = Int(text),
              value >= 3 else {
            return
        }
        
        dismiss(animated: false)
        delegate?.addTip(vc: self, cents: value * 100)
    }
    
    // MARK: Text field delegate
    
    @objc
    func textFieldDidChange(_ field: UITextField) {
        enableTipButtonIfNeeded()
    }
    
    // MARK: Pan gesture
    
    var prevY: CGFloat = 0
    @IBAction func viewDragged(_ sender: Any) {
        let translation = panGesture.translation(in: sheetView)
    
        if panGesture.state == .began {
            prevY = 0
        }
        
        if translation.y > 0 && panGesture.state == .changed {
            let distanceTraveled = translation.y - prevY
            prevY = translation.y

            bottomConstraint.constant -= distanceTraveled
            changeAlpha()
            
        } else if translation.y < 0 {
            animateToConstraintValue(value: 0)
            prevY = 0
        }
        
        
        if panGesture.state == .ended || panGesture.state == .cancelled {
            if abs(bottomConstraint.constant) < sheetView.frame.height / 2.0 {
                open(alpha: true)
            } else {
                close(alpha: true)
            }
        }
    }
    
    // MARK: Private methods
    
    private func open(alpha: Bool) {
        animateToConstraintValue(value: 0, alpha: alpha)
    }
    
    private func close(dismissVC: Bool = true, alpha: Bool) {
        animateToConstraintValue(value: -sheetView.frame.height, alpha: alpha, dismiss: dismissVC)
    }
    
    private func animateToConstraintValue(value: CGFloat, alpha: Bool = true, dismiss: Bool = false) {
        if alpha == false {
            self.bottomConstraint.constant = value
            return
        }
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.bottomConstraint.constant = value
            self.changeAlpha()
            self.view.layoutIfNeeded()
            
        } completion: { (_) in
            if dismiss {
                self.presentingViewController?.dismiss(animated: false, completion: {
                    self.completion?()
                })
            }
        }
    }
    
    private func changeAlpha() {
        let A = Double(sheetView.frame.height)
        let B = 0.0
        
        let a = 0.5
        let b = 0.0
        
        let val = Double(abs(bottomConstraint.constant))
        
        let nominator = (val - A) * (b - a)
        let denominator = (B - A) + a
        
        let value = nominator / denominator
        visualView.alpha = CGFloat(abs(value))
    }
    
    private func enableTipButtonIfNeeded() {
        guard let text = amountField.text,
              let value = Int(text),
              value >= 3 else {
            
            giveTipButton.set(active: false)
            
            return
        }
        
        giveTipButton.set(active: true)
    }

}

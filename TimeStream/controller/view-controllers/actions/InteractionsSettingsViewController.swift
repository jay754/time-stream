//
//  EnableInteractionsViewController.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit

enum InteractionsSettingsType {
    case enable
    case disable
}


protocol InteractionsSettingsViewControllerDelegate: class {
    func interactionsSettingsEnableInteractions(vc: InteractionsSettingsViewController, count: Int)
    func interactionsSettingsDisableInteractions(vc: InteractionsSettingsViewController)
}

class InteractionsSettingsViewController: BaseViewController, DisableInteractionViewProtocol, EnableInteractionsViewProtocol {
    
    @discardableResult static func displayFrom(vc: UIViewController, type: InteractionsSettingsType, delegate: InteractionsSettingsViewControllerDelegate?, completion: @escaping EmptyClosure) -> InteractionsSettingsViewController {
        let controller =
            InteractionsSettingsViewController(nibName: "InteractionsSettingsViewController", bundle: nil)
        
        controller.completion = completion
        controller.delegate = delegate
        controller.modalPresentationStyle = .overFullScreen
        controller.type = type
        vc.present(controller, animated: false, completion: nil)
        
        
        return controller
    }
    
    weak var delegate: InteractionsSettingsViewControllerDelegate?

    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var sheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var visualView: UIVisualEffectView!
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var completion: EmptyClosure?
    fileprivate var type: InteractionsSettingsType!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        changeType()
        close(dismissVC: false, alpha: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        open(alpha: true)
    }
    
    // MARK: Methods
    
    func close() {
        close(dismissVC: true, alpha: true)
    }
    
    // MARK: Actions
    
    @IBAction func closeTapped(_ sender: Any) {
        close(dismissVC: true, alpha: true)
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

    
    // MARK: Containers private
    
    private func changeType() {
        stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        switch type {
        case .disable:
            let disable = DisableInteractionsView.loadFromNib()
            disable.delegate = self
            stackView.addArrangedSubview(disable)
            
        case .enable:
            let enable = EnableInteractionsView.loadFromNib()
            enable.delegate = self
            stackView.addArrangedSubview(enable)
            
        case .none:
            break
        }
    }
    
    // MARK: Disable enable
    
    func disableInteractionsPressed() {
        delegate?.interactionsSettingsDisableInteractions(vc: self)
    }
    
    func enableInteractionsPressed(count: Int) {
        delegate?.interactionsSettingsEnableInteractions(vc: self, count: count)
    }
    
}

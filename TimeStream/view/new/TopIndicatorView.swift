//
//  TopIndicatorView.swift
//  TimeStream
//
//  Created by appssemble on 02.10.2021.
//

import UIKit

protocol TopIndicatorViewDelegate: class {
    func topIndicatorTimeElapsed(view: TopIndicatorView)
    func topIndicatorTimeRemaining(view: TopIndicatorView, seconds: Int)
}

class TopIndicatorView: UIView {
    
    weak var delegate: TopIndicatorViewDelegate?

    @IBOutlet weak var stackView: UIStackView!
    
    var initialSeconds: Int = 0
    var currentCount = 0
    var prevTimer: Timer?
    var stop: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        stackView.removeAllArrangedSubviews()
        addHeightConstraint(value: 8)
    }
    
    func startCountDown(seconds: Int) {
        stop = false
        initialSeconds = seconds
        currentCount = 0
        
        prevTimer?.invalidate()
        prevTimer = nil
        
        remaining(seconds: seconds)
        stackView.removeAllArrangedSubviews()
        
        prevTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let strong = self, strong.currentCount < strong.initialSeconds - 1, strong.stop == false else {
                timer.invalidate()
                
                if self?.stop == false {
                    self?.timerElapsed()
                }
                
                self?.addPortion(seconds: seconds)
                return
            }
            
            strong.currentCount += 1
            strong.remaining(seconds: seconds - strong.currentCount)
            strong.addPortion(seconds: seconds)
        }
    }
    
    private func addPortion(seconds: Int) {
        let fullWidth = bounds.width
        let portion = fullWidth / CGFloat(seconds)
        let portionView = UIView()
        portionView.backgroundColor = .accent
        portionView.addWidthConstraint(value: portion)
        stackView.addArrangedSubview(portionView)
    }
    
    private func timerElapsed() {
        delegate?.topIndicatorTimeElapsed(view: self)
    }
    
    private func remaining(seconds: Int) {
        delegate?.topIndicatorTimeRemaining(view: self, seconds: seconds)
    }
}

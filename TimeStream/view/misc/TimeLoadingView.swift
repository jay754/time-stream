//
//  LoadingView.swift
//  Company space planner
//
//  Created by appssemble on 20/05/2020.
//  Copyright © 2020 Zenitech. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ALProgressView

class TimeLoadingView: UIView {

    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var progressContainerView: UIView!
    
    private let progressView = ALProgressRing(frame: CGRect.zero)
    
    var loading = false {
        didSet {
            if loading == true {
                progressContainerView.isHidden = true
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func commonInit() {
        progressContainerView.addSubview(progressView)
        progressView.pinToSuperview()
        progressContainerView.isHidden = true
        
        progressView.startColor = .accent
        progressView.endColor = .accent
        progressView.lineWidth = 5
        progressView.grooveWidth = 2
    }
    
    func showProgress(progress: Float) {
        progressContainerView.isHidden = false
        progressView.setProgress(progress, animated: true)
    }
    
    func stopProgress() {
        progressContainerView.isHidden = true
        
    }
}

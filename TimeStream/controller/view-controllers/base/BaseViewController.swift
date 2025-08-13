//
//  BaseViewController.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import UIKit
import AVFoundation


typealias EmptyClosure = () -> Void

fileprivate var activityIndicatorKey: UInt8 = 0

class BaseViewController: UIViewController {
    
    private struct Constants {
        static let spinnerSize = 40
    }
    
    var hideStatusBar: Bool = false
    
    private(set) var visibleViews = [UIView]()
    
    var activityIndicator: TimeLoadingView! {
        get {
            if let indicator = objc_getAssociatedObject(self, &activityIndicatorKey) as? TimeLoadingView {
                return indicator
            } else {
                let indicator = TimeLoadingView.loadFromNib()
                objc_setAssociatedObject(self, &activityIndicatorKey, indicator, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return indicator
            }
        }
    }
    
    var disableLoadingShow = false
    
    var loading: Bool {
        get {
            return activityIndicator.loading
        }
        
        set(shouldAnimate) {
            if disableLoadingShow {
                return
            }
            
            if shouldAnimate {
                view.isUserInteractionEnabled = false
                showActivityIndicator()
                activityIndicator.loading = true
            } else {
                view.isUserInteractionEnabled = true
                activityIndicator.loading = false
                hideActivityIndicator()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hideStatusBar {
            setStatusBar(hidden: hideStatusBar)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hideStatusBar {
            setStatusBar(hidden: false)
        }
    }
    
    private var flowDelegate: BaseViewControllerFlowDelegate?
    
    // MARK: Navigation helper
    
    func addBackButton(delegate: BaseViewControllerFlowDelegate?) {
        flowDelegate = delegate
        
        addBackButton(selector: #selector(backPressed))
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    // MARK: Private methods
    
    private func setStatusBar(hidden: Bool) {
        if #available(iOS 13.0, *) {} else {
            UIApplication.shared.isStatusBarHidden = hidden
        }

        if !hidden {
            self.navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc
    private func backPressed() {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    func makeImpactVibration(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    func showSharePopup(sharedContent: [Any], success: EmptyClosure? = nil) {
        let activityVC = UIActivityViewController(activityItems: sharedContent,
                                                  applicationActivities: nil)
        if UIDevice.current.iPad {
            activityVC.popoverPresentationController?.sourceView = self.view
        }
        
        // exclude some activity types from the list
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.print,
                                            UIActivity.ActivityType.addToReadingList,
                                            UIActivity.ActivityType.postToVimeo
        ]
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                success?()
            }
        }
        
        DispatchQueue.main.async {
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    // MARK: Progress
    
    func setLoading(progress: Float) {
        showActivityIndicator()
        activityIndicator.showProgress(progress: progress)
    }
    
    func stopLoadingWithProgress() {
        hideActivityIndicator()
        activityIndicator.stopProgress()
    }
    
    // MARK: Private methods
    
    private func showActivityIndicator() {
        guard activityIndicator.superview == nil else {
             return
        }
        
        var origin = view.center
        origin.x -= CGFloat(Constants.spinnerSize / 2)
        origin.y -= CGFloat(Constants.spinnerSize / 2)
        
        activityIndicator.frame = CGRect(origin: origin, size: CGSize(width: Constants.spinnerSize, height: Constants.spinnerSize))
        activityIndicator.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        activityIndicator.tintColor = UIColor.blue
        
        view.addSubview(activityIndicator)
    }
    
    private func hideActivityIndicator() {
        activityIndicator.removeFromSuperview()
    }
}



//
//  ResponseOverviewViewController.swift
//  TimeStream
//
//  Created by appssemble on 28.10.2021.
//

import UIKit
import CameraKit_iOS
import AVKit

protocol ResponseOverviewViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func responsePreviewGoToEditVideo(vc: ResponseOverviewViewController, url: URL, maxDuration: Int, editDelegate: EditVideoViewControllerTrimDelegate?)
    func responsePreviewHasSentResponse(vc: ResponseOverviewViewController)
}

class ResponseOverviewViewController: BaseViewController, TopIndicatorViewDelegate, EditVideoViewControllerTrimDelegate {
    
    private struct Constants {
        static let timeLimit: Int = 180
    }
    
    weak var flowDelegate: ResponseOverviewViewControllerFlowDelegate?
    var url: URL!
    var message: VideoMessage!
    var conversation: Conversation!
    
    @IBOutlet weak var durationIndicatorContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var continueButton: ConfirmationButton!
    
    private let topIndicatorView = TopIndicatorView.loadFromNib()
    private let conversationService = ConversationService()
    private var adyenHelper: AdyenPaymentHelper!
    
    private var thumbnail: UIImage!
    
    // Playing
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adyenHelper = AdyenPaymentHelper(vc: self)

        // Do any additional setup after loading the view.
        durationIndicatorContainer.addSubview(topIndicatorView)
        topIndicatorView.pinToSuperview()
        topIndicatorView.delegate = self
        
        enableNextButtonIfNeeded()
        
        guard let image = VideoHelper.generateThumbnail(url: url) else {
            flowDelegate?.backButtonPressed(from: self)
            
            return
        }
        
        thumbnail = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        setPlayback(url: url)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stop()
    }

    // MARK: Actions
    
    @IBAction func back(_ sender: Any) {
        stop()
        flowDelegate?.backButtonPressed(from: self)
    }
    
    @IBAction func trimVideo(_ sender: Any) {
        flowDelegate?.responsePreviewGoToEditVideo(vc: self, url: url, maxDuration: Constants.timeLimit, editDelegate: self)
    }
 
    @IBAction func continuePressed(_ sender: Any) {
        loading = true
        adyenHelper.hasBankAccountAdded { (result) in
            self.loading = false

            switch result {
            case .error:
                self.showGenericError()

            case .success(let account):
                if !account.accountValid || account.pendingAuthorization {
                    // If the account is not yet authorized or there are pending authorizations, redirect to Stripe account setup
                    self.showAlert(message: "set.bank.message".localized) {
                        self.openBankAccount()
                    }

                } else {
                    self.addVideoResponse()
                }
            }
        }
    }
    
    // MARK: TopIndicatorViewDelegate
    
    func topIndicatorTimeElapsed(view: TopIndicatorView) {
        setTime(seconds: 0)
    }
    
    func topIndicatorTimeRemaining(view: TopIndicatorView, seconds: Int) {
        setTime(seconds: seconds)
    }
    
    // MARK: Trim delegate
    
    func editVideoControllerHasModifiedVideo(vc: EditVideoViewController, oldURL: URL, newURL: URL) {
        url = newURL
    }
    
    // MARK: Private methods
    
    private func openBankAccount() {
        adyenHelper.openOnboardingScreen { [weak self] in
            // Do nothing
        }
    }
    
    private func addVideoResponse() {
        loading = false
        setLoading(progress: 0)
        continueButton.isHidden = true
        conversationService.addVideoResponse(message: message, video: url, thumbnail: thumbnail) { progress in
            self.setLoading(progress: progress)
            
            if progress == 1 {
                self.stopLoadingWithProgress()
                self.loading = true
            }
            
        } completion: { result in
            self.continueButton.isHidden = false
            self.loading = false
            self.stopLoadingWithProgress()
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.flowDelegate?.responsePreviewHasSentResponse(vc: self)
            }
        }
    }
    
    private func stop() {
        player?.pause()
        player = nil
        looper = nil
        playerLayer?.removeFromSuperlayer()
        topIndicatorView.stop = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setTime(seconds: Int) {
        timerLabel.text = "respond.to".localized + " " + conversation.otherUser.name + "\n" + seconds.secondsToTime()
    }
    
    private func setPlayback(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player = AVQueuePlayer(playerItem: item)
        looper = AVPlayerLooper(player: player!, templateItem: item)
        
        playerLayer = AVPlayerLayer(player: player!)
        
        guard let playerLayer = playerLayer else {
            flowDelegate?.backButtonPressed(from: self)
            showGenericError()
            return
        }
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = cameraView.bounds
        cameraView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        cameraView.layer.addSublayer(playerLayer)
        
        let cm = asset.duration
        let time = Int(ceil(cm.seconds))
        
        player?.play()
        topIndicatorView.startCountDown(seconds: time)
        
        if time > Constants.timeLimit {
            timerLabel.textColor = .red
        } else {
            timerLabel.textColor = .white
        }
        
        enableNextButtonIfNeeded()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.topIndicatorView.startCountDown(seconds: time)
        }
    }
    
    private func enableNextButtonIfNeeded() {
        let asset = AVAsset(url: url)
    
        let cm = asset.duration
        let time = Int(ceil(cm.seconds))
        
        continueButton.set(active: time <= Constants.timeLimit)
    }
}

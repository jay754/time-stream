//
//  RequestOverviewViewController.swift
//  TimeStream
//
//  Created by appssemble on 29.10.2021.
//

import UIKit

import CameraKit_iOS
import AVKit

protocol RequestOverviewViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func requestPreviewHasSentRequest(vc: RequestOverviewViewController)
}

class RequestOverviewViewController: BaseViewController, TopIndicatorViewDelegate {
    
    private struct Constants {
        static let timeLimit: Int = 60
    }
    
    weak var flowDelegate: RequestOverviewViewControllerFlowDelegate?
    var url: URL!
    var user: User!
    
    @IBOutlet weak var durationIndicatorContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var continueButton: ConfirmationButton!
    
    private let topIndicatorView = TopIndicatorView.loadFromNib()
    private var paymentHelper: AdyenPaymentHelper!
    private let conversationService = ConversationService()
    
    // Playing
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    
    private var thumbnail: UIImage!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        durationIndicatorContainer.addSubview(topIndicatorView)
        topIndicatorView.pinToSuperview()
        topIndicatorView.delegate = self
        
        enableNextButtonIfNeeded()
        
        let buttonTitle = "request.button.title".localized + user.formattedPrice
        continueButton.setTitle(buttonTitle, for: .normal)
        
        paymentHelper = AdyenPaymentHelper(vc: self)
        
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
 
    @IBAction func continuePressed(_ sender: Any) {
        loading = true
        paymentHelper.startPaymentSheet(creatorID: user.id) { status in
            self.loading = false
            
            switch status {
            case .successfull(let paymentIntent):
                self.startVideoMessageCreation(paymentIntent: paymentIntent)
                
            case .canceled:
                break
                
            case .failed:
                self.showGenericError()

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
    
    private func startVideoMessageCreation(paymentIntent: PaymentIntent) {
        loading = false
        setLoading(progress: 0.0)
        continueButton.isHidden = true
        conversationService.addVideoRequest(video: url, thumbnail: thumbnail, paymentIntent: paymentIntent, forUser: user, progress: { progress in
           
            self.setLoading(progress: progress)
            
            if progress > 0.9 {
                self.stopLoadingWithProgress()
                self.loading = true
            }
            
        }) { result in
            self.loading = false
            self.stopLoadingWithProgress()
            self.continueButton.isHidden = false
            
            switch result {
            case .error(let error):
                self.continueButton.isHidden = false
                if let error = error {
                    self.showAlert(title: "oops".localized, message: error.localizedDescription)
                } else {
                    self.showGenericError()
                }
                
            case .success:
                // Create the video message
                self.flowDelegate?.requestPreviewHasSentRequest(vc: self)
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
        timerLabel.text = "request.for".localized + " " + user.name + "\n" + seconds.secondsToTime()
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

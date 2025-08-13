//
//  PreviewRecordingViewController.swift
//  TimeStream
//
//  Created by appssemble on 02.10.2021.
//

import UIKit
import CameraKit_iOS
import AVKit

protocol PreviewRecordingFlowDelegate: BaseViewControllerFlowDelegate {
    func previewGoToEditVideo(vc: PreviewRecordingViewController, url: URL, editDelegate: EditVideoViewControllerTrimDelegate?)
    func previewGoAddDetails(vc: PreviewRecordingViewController, url: URL)
}

class PreviewRecordingViewController: BaseViewController, TopIndicatorViewDelegate, EditVideoViewControllerTrimDelegate {
    
    weak var flowDelegate: PreviewRecordingFlowDelegate?
    var url: URL!
    
    @IBOutlet weak var durationIndicatorContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var continueButton: ConfirmationButton!
    
    private let topIndicatorView = TopIndicatorView.loadFromNib()
    
    // Playing
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        durationIndicatorContainer.addSubview(topIndicatorView)
        topIndicatorView.pinToSuperview()
        topIndicatorView.delegate = self
        
        enableNextButtonIfNeeded()
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
        flowDelegate?.previewGoToEditVideo(vc: self, url: url, editDelegate: self)
    }
 
    @IBAction func continuePressed(_ sender: Any) {
        flowDelegate?.previewGoAddDetails(vc: self, url: url)
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
    
    private func stop() {
        player?.pause()
        player = nil
        looper = nil
        playerLayer?.removeFromSuperlayer()
        topIndicatorView.stop = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setTime(seconds: Int) {
        timerLabel.text = seconds.secondsToTime()
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
        
        if time > 60 {
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
        let time = Int(cm.seconds)
        
        continueButton.set(active: time <= 60)
    }
}

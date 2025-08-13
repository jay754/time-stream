//
//  EditVideoViewController.swift
//  TimeStream
//
//  Created by appssemble on 02.10.2021.
//

import UIKit
import CameraKit_iOS
import AVKit

protocol EditVideoViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    
}

protocol EditVideoViewControllerTrimDelegate: class {
    func editVideoControllerHasModifiedVideo(vc: EditVideoViewController, oldURL: URL, newURL: URL)
}

class EditVideoViewController: BaseViewController {

    weak var flowDelegate: EditVideoViewControllerFlowDelegate?
    
    var url: URL!
    weak var trimDelegate: EditVideoViewControllerTrimDelegate?
    var trimMaxDuration = 60 // seconds
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var trimmerView: TrimmerView!
    private var playbackTimeCheckerTimer: Timer?
    
    // Playing
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var asset: AVAsset!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        asset = AVAsset(url: url)
        trimmerView.delegate = self
        timerLabel.text = nil
        trimmerView.maxDuration = Double(trimMaxDuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setPlayback(url: url)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        trimmerView.asset = asset
        setDuration()
        togglePlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stop()
    }

    // MARK: Actions

    @IBAction func cameraTapped(_ sender: Any) {
        togglePlay()
    }
    
    @IBAction func back(_ sender: Any) {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        flowDelegate?.backButtonPressed(from: self)
    }

    @IBAction func saveVideo(_ sender: Any) {
        guard let start = trimmerView.startTime, let end = trimmerView.endTime else {
            return
        }
        
        loading = true
        trimVideo(sourceURL: url, statTime: start.seconds, endTime: end.seconds) { (newURL) in
            self.loading = false
            guard let newURL = newURL else {
                self.showGenericError()
                return
            }
            
            // All good
            self.trimDelegate?.editVideoControllerHasModifiedVideo(vc: self, oldURL: self.url, newURL: newURL)
            self.flowDelegate?.backButtonPressed(from: self)
        }
    }

    // MARK: Private methods
    
    private func stop() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        
        stopPlaybackTimeChecker()
        NotificationCenter.default.removeObserver(self)
    }

    private func setPlayback(url: URL) {
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player!)

        guard let playerLayer = playerLayer else {
            flowDelegate?.backButtonPressed(from: self)
            showGenericError()
            return
        }

        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            
            if let startTime = self.trimmerView.startTime {
                self.player?.seek(to: startTime)
                if (self.player?.isPlaying != true) {
                    self.player?.play()
                }
            }
        }
    }

    private func setDuration() {
        guard let start = trimmerView.startTime, let end = trimmerView.endTime else {
            return
        }
        
        let duration = (end - start).seconds
        timerLabel.text = Int(duration).secondsToTime()
    }

    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.onPlaybackTimeChecker()
        }
    }

    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }

    @objc
    private func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }

        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
    
    private func togglePlay() {
        guard let player = player else { return }

        if !player.isPlaying {
            player.play()
            startPlaybackTimeChecker()
        } else {
            player.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    private func trimVideo(sourceURL: URL, statTime: Double, endTime: Double, completion: @escaping ShareURL) {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            
            completion(nil)
            return
        }
        
        let asset = AVAsset(url: sourceURL as URL)
        let start = statTime
        let end = endTime
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).mp4")
        } catch _ {
            completion(nil)
        }
        
        //Remove existing file
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetHighestQuality) else {
            
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    // All good
                    completion(outputURL)

                default:
                    completion(nil)
                }
            }
        }
    }
}

extension EditVideoViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        setDuration()
    }
}

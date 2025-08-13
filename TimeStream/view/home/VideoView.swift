//
//  HomeVideoView.swift
//  TimeStream
//
//  Created  on 16.07.2021.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

protocol VideoViewDelegate: AnyObject {
    func videoViewHasLoopedVideo(view: VideoView, videoURL: URL)
}

class VideoView: UIView {
    
    weak var delegate: VideoViewDelegate?
    
    @IBOutlet weak var spinner: NVActivityIndicatorView!
    private var player = AVQueuePlayer()
    private var playerLayer: AVPlayerLayer?
    private var looper: AVPlayerLooper?

    var videoURL: URL? {
        didSet {
            if let videoURL = videoURL {
                let item = AVPlayerItem(url: videoURL)
                player.insert(item, after: nil)
                
                looper?.removeObserver(self, forKeyPath: "loopCount")
                looper = AVPlayerLooper(player: player, templateItem: item)
                looper?.addObserver(self, forKeyPath: "loopCount", options: .new, context: nil)
            } else {
                clearMedia()
            }
        }
    }

    var isPlaying: Bool {
        get {
            return player.isPlaying
        }
        
        set {
            if newValue {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    // MARK: Overwritten
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer!)
        
        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        clipsToBounds = true
        
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player.rate > 0 {
                spinner.stopAnimating()
            }
        }
        
        if keyPath == "loopCount" {
            guard let url = videoURL else {
                return
            }
            
            delegate?.videoViewHasLoopedVideo(view: self, videoURL: url)
        }
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "rate")
        looper?.removeObserver(self, forKeyPath: "loopCount")
    }
    
    // MARK: Methods
    
    func setMedia(url:URL) {
        clearMedia()
        videoURL = url
    }
    
    func stop() {
        looper?.disableLooping()
        player.removeAllItems()
    }
    
    // MARK: Private methods
    
    private func clearMedia() {
        looper?.disableLooping()
    }

}

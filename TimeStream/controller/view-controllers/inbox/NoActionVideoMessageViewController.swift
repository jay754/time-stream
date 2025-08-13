//
//  NoActionVideoMessageViewController.swift
//  TimeStream
//
//  Created by appssemble on 05.11.2021.
//

import UIKit

protocol NoActionVideoMessageViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    
}

class NoActionVideoMessageViewController: BaseViewController {
    
    weak var flowDelegate: NoActionVideoMessageViewControllerFlowDelegate?
    var message: VideoMessage!
    var conversation: Conversation!
    
    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let videoView = VideoView.loadFromNib()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        videoViewContainer.addSubview(videoView)
        videoView.setMedia(url: message.videoPath)
        
        guard let currentUser = Context.current.user else {
            return
        }
        
        if currentUser.id == message.userID {
            titleLabel.text = "your.message".localized
        } else {
            titleLabel.text = conversation.otherUser.name
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoView.isPlaying = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.isPlaying = false
    }
    
    // MARK: Actions

    @IBAction func videoTap(_ sender: Any) {
        videoView.isPlaying = !videoView.isPlaying
    }
    
    @IBAction func backPressed(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
}

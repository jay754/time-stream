//
//  ReplyViewController.swift
//  TimeStream
//
//  Created by appssemble on 01.11.2021.
//

import UIKit

protocol ReplyViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    
    func replyAddMessageToProfile(vc: ReplyViewController, message: VideoMessage, conversation: Conversation)
    
}

class ReplyViewController: BaseViewController {
    
    weak var flowDelegate: ReplyViewControllerFlowDelegate?
    var message: VideoMessage!
    var conversation: Conversation!
    
    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addToProfileButton: UIButton!
    
    private let videoView = VideoView.loadFromNib()
    private let conversationService = ConversationService()
    private let reportHelper = ReportHelper()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        videoViewContainer.addSubview(videoView)
        videoView.setMedia(url: message.videoPath)
        
        titleLabel.text = "reply.from".localized + " " + conversation.otherUser.name
        
        addToProfileButton.isHidden = message.postedVideoID != nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        markVideoAsSeen()
        
        videoView.isPlaying = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.isPlaying = false
    }
    
    // MARK: Actions
    
    @IBAction func moreAction(_ sender: Any) {
        reportHelper.reportConversationVideo(videoMessageID: message.id, from: self)
    }

    @IBAction func videoTap(_ sender: Any) {
        videoView.isPlaying = !videoView.isPlaying
    }
    
    @IBAction func addToProfile(_ sender: Any) {
        flowDelegate?.replyAddMessageToProfile(vc: self, message: message, conversation: conversation)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        flowDelegate?.backButtonPressed(from: self)
    }
    
    // MARK: Private methods
    
    private func markVideoAsSeen() {
        conversationService.markVideoMessageAsSeen(message: message) { result in
            // Do nothing
        }
    }
}

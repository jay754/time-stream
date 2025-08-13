//
//  InboxTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 29.10.2021.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var newMessageIndicatorView: UIView!
    @IBOutlet weak var messageTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    func populate(conversation: Conversation) {
        userNameLabel.text = conversation.otherUser.name
        userImageView.setUserImage(url: conversation.otherUser.photoURL)
        
        dateLabel.text = conversation.lastVideo.createdAt.prettyFormattedSmall()
        
        newMessageIndicatorView.isHidden = conversation.lastVideo.seen

        switch conversation.lastVideo.type {
        case .interact:
            if conversation.lastVideo.seen {
                messageTypeLabel.text = "video.request".localized
            } else {
                messageTypeLabel.text = "new.video.request".localized
            }
        case .response:
            if conversation.lastVideo.seen {
                messageTypeLabel.text = "video.response".localized
            } else {
                messageTypeLabel.text = "new.video.response".localized
            }
        case .declined:
            messageTypeLabel.text = "video.declined".localized
        }
    }
}

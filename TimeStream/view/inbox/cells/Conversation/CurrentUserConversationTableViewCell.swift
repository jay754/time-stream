//
//  CurrentUserConversationTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 01.11.2021.
//

import UIKit

class CurrentUserConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.tintColor = .white
    }
    
    // MARK: Methods
    
    func populate(message: VideoMessage) {
        timeLabel.text = message.createdAt.prettyFormattedSmall()
        setType(type: message.type)
        thumbnailImageView.setImage(url: message.thumbnailPath)
    }
    
    // MARK: Methods
    
    func setType(type: VideoMessageType) {        
        switch type {
        case .interact:
            button.backgroundColor = UIColor.accent
            button.setImage(UIImage(named: "interact-icon"), for: .normal)
        case .response:
            button.backgroundColor = UIColor.unselectedContainerText
            button.setImage(UIImage(named: "camera-template"), for: .normal)
        case .declined:
            button.backgroundColor = UIColor.destroyColor
            button.setImage(UIImage(named: "close-white-icon"), for: .normal)
        }
        
    }
}

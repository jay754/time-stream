//
//  CurrentProfileVideoCollectionViewCell.swift
//  TimeStream
//
//  Created by appssemble on 13.08.2021.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var numberOfViewsLabel: UILabel!
    
    func populate(video: Video) {
        if let tag = video.tags.last {
            hashtagLabel.text = "#" + tag
        }
        
        thumbnailImageView.setImage(url: video.thumbnailURL)
        numberOfViewsLabel.text = video.numberOfViews
    }

}

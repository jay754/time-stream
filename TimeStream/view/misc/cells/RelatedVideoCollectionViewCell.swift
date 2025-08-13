//
//  RelatedVideoCollectionViewCell.swift
//  TimeStream
//
//  Created by appssemble on 06.10.2021.
//

import UIKit

class RelatedVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    
    func populate(video: Video) {
        viewsLabel.text = video.numberOfViews
        thumbnailImageView.setImage(url: video.thumbnailURL)
        
        guard let tag = video.tags.last else {
            return
        }
        
        tagLabel.text = "#" + tag
    }
}

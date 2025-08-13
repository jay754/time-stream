//
//  VideoTagsView.swift
//  TimeStream
//
//  Created by appssemble on 16.07.2021.
//

import UIKit

class VideoTagsView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // MARK: Methods
    
    func setTags(video: Video) {
        stackView.removeAllArrangedSubviews()
        for tag in video.tags.reversed() {
            let item = VideoTagView.loadFromNib()
            item.videoTagLabel.text = "#" + tag
            stackView.addArrangedSubview(item)
        }
    }

}

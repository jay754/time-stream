//
//  VideoUploadHashtag.swift
//  TimeStream
//
//  Created by appssemble on 05.10.2021.
//

import UIKit

protocol VideoUploadHashtagDelegate: class {
    func videoHashtagDelete(view: VideoUploadHashtag, tag: String)
}

class VideoUploadHashtag: UIView {

    weak var delegate: VideoUploadHashtagDelegate?
    
    @IBOutlet weak var label: UILabel!

    private var hashtag: String?
    
    // MARK: Actions
    
    func populate(tag: String) {
        hashtag = tag
        label.text = tag
    }
    
    // MARK: Actions

    @IBAction func closed(_ sender: Any) {
        guard let hashtag = hashtag else {
            return
        }
        
        delegate?.videoHashtagDelete(view: self, tag: hashtag)
    }
}

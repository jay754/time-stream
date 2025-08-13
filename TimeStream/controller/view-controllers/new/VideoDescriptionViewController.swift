//
//  VideoDescriptionViewController.swift
//  TimeStream
//
//  Created on 05.10.2021.
//

import UIKit
import AVKit

typealias PresignedUploadClosure = (_ url: PresignedUpload) -> Void
typealias OptionalPresignedUploadClosure = (_ url: PresignedUpload?) -> Void

protocol VideoDescriptionFlowDelegate: BaseViewControllerFlowDelegate {
    func videoWasUploaded(vc: VideoDescriptionViewController)
    func videoDescriptionPickCateogry(vc: VideoDescriptionViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate)
}

class VideoDescriptionViewController: BaseViewController, VideoUploadHashtagDelegate, UITextViewDelegate, UITextFieldDelegate, AssetPickerProtocol, CategoryPickerActionDelegate {
    
    weak var flowDelegate: VideoDescriptionFlowDelegate?
    
    var videoURL: URL!
    
    
    private struct Constants {
        static let numberOfAllowedDescriptionCharacters = 140
    }
    
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addHashtagField: UITextField!
    @IBOutlet weak var postButton: ConfirmationButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectedCategoryLabel: UILabel!
    
    private var hashtags = [String]()
    private var assetPicker: AssetPickerHelper!
    
    private var pickedImage: UIImage?
    private let videoService = VideoService()
    private var selectedCategory: Category! {
        didSet {
            selectedCategoryLabel.text = selectedCategory.name
        }
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assetPicker = AssetPickerHelper(viewController: self)
        assetPicker.delegate = self
        
        addBackButton(delegate: flowDelegate)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        enableButtonIfNeeded()
        descriptionTextView.delegate = self
        
        addHashtagField.attributedPlaceholder = NSAttributedString.placeholderText(text: "new.video".localized, light: ["new.video.min".localized])
        addHashtagField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addHashtagField.delegate = self
        
        guard let image = VideoHelper.generateThumbnail(url: videoURL) else {
            flowDelegate?.backButtonPressed(from: self)

            return
        }

        pickedImage = image
        thumbnailImageView.image = image
        
        guard let user = Context.current.user else {
            flowDelegate?.backButtonPressed(from: self)
            return
        }
        
        selectedCategory = user.expertise
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: Actions
    
    @IBAction func editPlacehored(_ sender: Any) {
        assetPicker.pickImage()
    }
    
    @IBAction func post(_ sender: Any) {
        guard let desc = descriptionTextView.text,
              desc.count >= 3,
              desc.count <= 140,
              let thumbnail = pickedImage,
              hashtags.count > 0 else {
                  
                  return
              }
        
        loading = true
        VideoHelper.encodeVideo(at: videoURL) { newUrl in
            self.loading = false
            
            guard let new = newUrl else {
                self.showGenericError()
                return
            }
            
            self.uploadVideo(videoURL: new)
        }
    }
    
    @IBAction func pickCategory(_ sender: Any) {
        flowDelegate?.videoDescriptionPickCateogry(vc: self, selectedCategory: selectedCategory, delegate: self)
    }
    
    // MARK: Asset picker delegate
    
    func didPickImage(helper: AssetPickerHelper, image: UIImage) {
        pickedImage = image
        thumbnailImageView.image = image
    }
    
    // MARK: Category picker delegate
    
    func categoryPickerDidPickCategory(vc: CategoryPickerViewController, category: Category) {
        selectedCategory = category
        selectedCategoryLabel.text = category.name
    }
    
    // MARK: Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = String(textView.text.prefix(Constants.numberOfAllowedDescriptionCharacters))
        
        enableButtonIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
        
        return true
    }
    
    // MARK: Text field delegate
    
    @objc
    func textFieldDidChange() {
        addHashtagField.text = addHashtagField.text?.replacingOccurrences(of: "\n", with: "").lowercased()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.count > 0 else {
            
            return false
        }
        
        hashtags.append(text)
        addHashtag(tag: text)
        textField.text = nil
        
        enableButtonIfNeeded()
        
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let whitespaceSet = NSCharacterSet.whitespaces
        let range = string.rangeOfCharacter(from: whitespaceSet)
        
        if let _ = range {
            return false
        } else {
            return true
        }
    }
    
    // MARK: Hashtag
    
    func videoHashtagDelete(view: VideoUploadHashtag, tag: String) {
        view.removeFromSuperview()
        hashtags.removeAll(where: {$0 == tag})
        enableButtonIfNeeded()
    }
    
    // MARK: Private methods
    
    private func uploadVideo(videoURL: URL) {
        guard let thumbnail = pickedImage,
              let desc = descriptionTextView.text,
              desc.count >= 3,
              desc.count <= 140,
              hashtags.count > 0,
              let category = selectedCategory,
              let user = Context.current.user else {
            showGenericError()
            return
        }
        
        let video = Video(id: 0, url: URL.dummyURL, description: desc, thumbnailURL: URL.dummyURL, createdAt: Date(), postedBy: user, tags: hashtags, likes: 0, views: 0, likedByCurrentUser: true, privateVideo: privateSwitch.isOn, category: category)
        
        loading = false
        setLoading(progress: 0.1)
        videoService.create(video: video, videoURL: videoURL, thumbnail: thumbnail) { progress in
            self.setLoading(progress: progress)
            
            if progress > 0.9 {
                self.setLoading(progress: 1)
                self.stopLoadingWithProgress()
                self.loading = true
            }
        } completion: { result in
            self.loading = false
            self.stopLoadingWithProgress()
            
            switch result {
            case .success:
                LocalNotifications.issueNotification(type: .videoUploaded)
                
                self.flowDelegate?.videoWasUploaded(vc: self)
                
            case .error:
                self.showGenericError()
            }
        }
    }
    
    private func addHashtag(tag: String) {
        let view = VideoUploadHashtag.loadFromNib()
        view.populate(tag: tag)
        view.delegate = self
        
        stackView.addArrangedSubview(view)
    }
    
    private func enableButtonIfNeeded() {
        if hashtags.count > 0,
           descriptionTextView.text.count >= 3 {
            
            postButton.set(active: true)
            
        } else {
            postButton.set(active: false)
        }
    }
}

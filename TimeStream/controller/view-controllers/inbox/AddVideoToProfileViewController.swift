//
//  AddVideoToProfileViewController.swift
//  TimeStream
//
//  Created on 09.11.2021.
//

import UIKit
import AVKit

protocol AddVideoToProfileViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func videoWasAddedToProfile(vc: AddVideoToProfileViewController)
    func videoSelectCategory(vc: AddVideoToProfileViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate)
}

class AddVideoToProfileViewController: BaseViewController, VideoUploadHashtagDelegate, UITextViewDelegate, UITextFieldDelegate, AssetPickerProtocol, CategoryPickerActionDelegate {
    
    weak var flowDelegate: AddVideoToProfileViewControllerFlowDelegate?
    
    var message: VideoMessage!
    var conversation: Conversation!
    
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
    private let conversationService = ConversationService()
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
        
        thumbnailImageView.setImage(url: message.thumbnailPath)
        
        selectedCategory = conversation.otherUser.expertise
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
              let category = selectedCategory,
              desc.count >= 3,
              desc.count <= 140,
              hashtags.count > 0 else {
                  
                  return
              }

        loading = false
        setLoading(progress: 0)
        conversationService.addVideoToProfile(message: message, thumbnail: pickedImage, privateVideo: privateSwitch.isOn, description: desc, tags: hashtags, category: category) { progress in
            
            self.setLoading(progress: progress)
            
            if progress == 1 {
                self.stopLoadingWithProgress()
                self.loading = true
            }
            
        } completion: { result in
            self.stopLoadingWithProgress()
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success:
                self.flowDelegate?.videoWasAddedToProfile(vc: self)
            }
        }

    }
    
    @IBAction func changeCategory(_ sender: Any) {
        flowDelegate?.videoSelectCategory(vc: self, selectedCategory: selectedCategory, delegate: self)
    }
    
    // MARK: Selected category delegate
    
    func categoryPickerDidPickCategory(vc: CategoryPickerViewController, category: Category) {
        selectedCategory = category
    }
    
    // MARK: Asset picker delegate
    
    func didPickImage(helper: AssetPickerHelper, image: UIImage) {
        pickedImage = image
        thumbnailImageView.image = image
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


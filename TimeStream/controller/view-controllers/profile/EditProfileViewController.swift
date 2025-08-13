//
//  EditProfileViewController.swift
//  TimeStream
//
//  Created  on 10.08.2021.
//

import UIKit
import Kingfisher

extension UITextView {
    
    func fullTextWith(range: NSRange, replacementString: String) -> String? {
        if let fullSearchString = self.text, let swtRange = Range(range, in: fullSearchString) {
            return fullSearchString.replacingCharacters(in: swtRange, with: replacementString)
        }

        return nil
    }
}

protocol EditProfileFlowDelegate: BaseViewControllerFlowDelegate {
    func editProfileChangePhoneNumber(vc: EditProfileViewController)
    func editProfileChangeExpertise(vc: EditProfileViewController, category: Category?, delegate: CategoryPickerActionDelegate)
}

class EditProfileViewController: BaseViewController, AssetPickerProtocol, UITextViewDelegate, CategoryPickerActionDelegate {
    
    weak var flowDelegate: EditProfileFlowDelegate?
    
    struct Constants {
        static let numberOfAllowedChars = 90
    }

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var phonenumberLabel: UILabel!
    @IBOutlet weak var saveButton: ConfirmationButton!
    @IBOutlet weak var domainOfExpertiseLabel: UILabel!
    
    private var photoHelper: AssetPickerHelper!
    private var pickedImage: UIImage?
    private let userService = UserService()
    private var skipPopulate = false
    private var selectedCategory: Category?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(delegate: flowDelegate)
        photoHelper = AssetPickerHelper(viewController: self)
        photoHelper.delegate = self
        
        nameTextField.attributedPlaceholder = NSAttributedString.placeholderText(text: "registration.placeholder".localized, light: ["registration.placeholder.min2".localized])
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        bioTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if !skipPopulate {
            populate()
        }
        
        skipPopulate = false
        
        LocalNotifications.addObserver(item: self, selector: #selector(userUpdated), type: .userChanged)
    }
    
    // MARK: Actions

    @IBAction func changeExperise(_ sender: Any) {
        skipPopulate = true
        flowDelegate?.editProfileChangeExpertise(vc: self, category: selectedCategory, delegate: self)
    }
    
    @IBAction func changePicture(_ sender: Any) {
        skipPopulate = true
        photoHelper.pickImage()
    }
    
    @IBAction func changePhoneNumber(_ sender: Any) {
        flowDelegate?.editProfileChangePhoneNumber(vc: self)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let user = newUser() else {
            return
        }
    
        update(user: user)
    }
    
    private func update(user: User) {
        loading = true
        userService.updateUser(user: user, photo: pickedImage) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.loading = true
                    self.flowDelegate?.backButtonPressed(from: self)
            }
        }
    }
    
    private func setBioPlaceholderIfNeeded() {
        if bioTextView.text.count == 0 {
            bioTextView.attributedText = NSAttributedString.placeholderText(text: "bio.placeholder".localized, light: ["bio.placeholder.min".localized])
        }
    }
    

    // MARK: Text field changes
    
    @objc
    private func textFieldDidChange() {
        enableSaveIfNeeded()
    }
    
    // MARK: Text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText.string.count > 0 && textView.attributedText.string == "bio.placeholder".localized  {
            textView.attributedText = NSAttributedString(string: "")
            textView.text = ""
            textView.textColor = UIColor.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setBioPlaceholderIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setBioCharCount()
        enableSaveIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let text = textView.fullTextWith(range: range, replacementString: text) {
            return text.count <= Constants.numberOfAllowedChars
        }
        
        return true
    }
    
    // MARK: Category picker delegate
    
    func categoryPickerDidPickCategory(vc: CategoryPickerViewController, category: Category) {
        selectedCategory = category
        domainOfExpertiseLabel.text = category.name
        enableSaveIfNeeded()
    }
    
    // MARK: Image picker

    func didPickImage(helper: AssetPickerHelper, image: UIImage) {
        pickedImage = image
        profileImageView.image = image
        enableSaveIfNeeded()
    }
    
    // MARK: Private methods
    
    @objc
    private func userUpdated() {
        populate()
    }
    
    private func setBioCharCount() {
        countLabel.text = "\(Constants.numberOfAllowedChars - bioTextView.text.count)"
    }
    
    private func enableSaveIfNeeded() {
        saveButton.set(active: newUser() != nil)
    }
    
    private func newUser() -> User? {
        guard let user = Context.current.user, (user.name != nameTextField.text && nameTextField.text?.count ?? 0 >= 2 && nameTextField.text?.count ?? 0 <= 100) || (user.bio != bioTextView.text && nameTextField.text?.count ?? 0 >= 2 && nameTextField.text?.count ?? 0 <= 100) || (pickedImage != nil) || (selectedCategory != nil) else {
            return nil
        }
        
        var bio = bioTextView.text
        if bio == "bio.placeholder".localized {
            bio = ""
        }
        
        var expertise = user.expertise
        if let categ = selectedCategory {
            expertise = categ
        }
        
        var newUser = User(id: user.id, firebaseID: user.firebaseID, name: nameTextField.text!, phoneNumber: user.phoneNumber, photoURL: user.photoURL, bio: bio, followers: user.followers, following: user.following, tipsEnabled:user.tipsEnabled, availableInteractions: user.availableInteractions, createdAt: user.createdAt, donationsAllowed: user.donationsAllowed, price: user.price, currency: user.currency, expertise: expertise, paymentDetailsCollected: user.paymentDetailsCollected, username: user.username)
        newUser.categoriesOfInterest = user.categoriesOfInterest
        
        return newUser
    }
    
    private func populate() {
        guard let user = Context.current.user else {
            flowDelegate?.backButtonPressed(from: self)
            showGenericError()
            return
        }
        
        nameTextField.text = user.name
        phonenumberLabel.text = user.phoneNumber
        profileImageView.setUserImage(url: user.photoURL)
        bioTextView.text = user.bio
        domainOfExpertiseLabel.text = user.expertise.name
        if let selectedCategory = selectedCategory {
            domainOfExpertiseLabel.text = selectedCategory.name
        }
        
        joinedLabel.text = "joined".localized + " \(user.createdAt.prettyFormattedSmall())"
        
        setBioCharCount()
        saveButton.set(active: newUser() != nil)
        setBioPlaceholderIfNeeded()
    }
    
}

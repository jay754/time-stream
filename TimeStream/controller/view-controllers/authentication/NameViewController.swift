//
//  NameViewController.swift
//  TimeStream
//
//  Created  on 04.07.2021.
//

import UIKit

protocol NameFlowDelegate: BaseViewControllerFlowDelegate {
    func nameHasRegisteredANewAccount(vc: NameViewController)
    func nameSelectCategory(vc: NameViewController, selectedCategory: Category?, delegate: CategoryPickerActionDelegate)
    func nameGoToWeb(vc: NameViewController, url: URL, title: String)
}

class NameViewController: BaseViewController, AssetPickerProtocol, CategoryPickerActionDelegate {
    
    weak var flowDelegate: NameFlowDelegate?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startButton: ConfirmationButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectedCategoryLabel: UILabel!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    private let userService = UserService()
    private var imagePicker: AssetPickerHelper!
    private var selectedCategory: Category?
    private let userDefaultsHelper = UserDefaultsHelper()
    private var termsSelected = false {
        didSet {
            if termsSelected {
                checkmarkImageView.image = UIImage(named: "checkmark-selected-icon")
                
            } else {
                checkmarkImageView.image = UIImage(named: "checkmark-deselected-icon")
            }
            
            enableIfNeeded()
        }
    }
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        title = nil
        navigationItem.hidesBackButton = true
        imagePicker = AssetPickerHelper(viewController: self)
        imagePicker.delegate = self
        
        nameField.attributedPlaceholder = NSAttributedString.placeholderText(text: "registration.placeholder".localized, light: ["registration.placeholder.min2".localized])
        nameField.addTextChangeObserver(item: self, selector: #selector(textFieldDidChange(_:)))
        
        termsSelected = false
        enableIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Actions
    
    @objc
    func textFieldDidChange(_ field: UITextField) {
        if field === nameField, field.text?.count ?? 0 > 100 {
            field.text = String(field.text!.prefix(100))
        }
        
        enableIfNeeded()
    }

    @IBAction func completeReg(_ sender: Any) {
        guard displayErrorMessageIfNeeded() == false,
              let _ = selectedImageView.image,
              let name = nameField.text,
              let _ = selectedCategory,
              termsSelected else {
            
            return
        }
        
        registerCurrentUser(name: name)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        view.endEditing(true)
        imagePicker.pickImage()
    }
    
    @IBAction func pickCategory(_ sender: Any) {
        view.endEditing(true)
        flowDelegate?.nameSelectCategory(vc: self, selectedCategory: selectedCategory, delegate: self)
    }
    
    @IBAction func toggleTerms(_ sender: Any) {
        termsSelected = !termsSelected
    }
    
    @IBAction func termsAndConditions(_ sender: Any) {
        view.endEditing(true)
        flowDelegate?.nameGoToWeb(vc: self, url: AppLinks.termsAndConditions, title: "terms".localized)
        termsSelected = true
    }
    
    // MARK: Category picker delegate
    
    func categoryPickerDidPickCategory(vc: CategoryPickerViewController, category: Category) {
        selectedCategory = category
        selectedCategoryLabel.text = category.name
        
        enableIfNeeded()
    }
    
    
    // MARK: Image picker helper
    
    func didPickImage(helper: AssetPickerHelper, image: UIImage) {
        selectedImageView.image = image
        enableIfNeeded()
    }
    
    // MARK: Private methods
    
    private func registerCurrentUser(name: String) {
        guard let image = selectedImageView.image?.resizeImage(targetWidth: 1024),
        let categ = selectedCategory else {
            return
        }
        
        let currency = Currency.current()
        let fcmToken = PushNotificationsManager.instance.pushNotificationsToken
        let categories = userDefaultsHelper.getCategories() ?? []
        
        loading = true
        userService.registerUser(name: name, currency: currency, FCMToken: fcmToken, photo: image, categories: categories, expertise: categ, progress: nil) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.flowDelegate?.nameHasRegisteredANewAccount(vc: self)
            }
        }

    }
    
    private func enableIfNeeded() {
        // Will remain enabled
        startButton.set(active: true)
    }
    
    private func displayErrorMessageIfNeeded() -> Bool {
        let hasImage = selectedImageView.image != nil
        let name = nameField.text?.count ?? 0 > 1 && nameField.text?.count ?? 0 <= 100
        let category = selectedCategory != nil
        
        var missingFields = [String]()
        
        if !hasImage {
            missingFields += ["add.a.profile.picture".localized]
        }
        
        if !name {
            missingFields += ["enter.your.name".localized]
        }
        
        if !category {
            missingFields += ["select.your.expertise".localized]
        }
        
        if !termsSelected {
            missingFields += ["agree.tc".localized]
        }
        
        if missingFields.count > 0 {
            // We have errors
            showAlert(title: "missing.fields".localized, message: "to.continue".localized + missingFields.joined(separator: ", ") + ".")
            return true
        }
        
        return false
    }
}

//
//  ReauthenticateCodeValidationViewController.swift
//  TimeStream
//
//  Created by appssemble on 15.07.2021.
//

import Foundation
import UIKit

protocol ReauthenticateCodeValidationFlowDelegate: BaseViewControllerFlowDelegate {
    func reauthenticatePhoneCodeValidationSuccesfullyChanged(vc: ReauthenticateCodeValidationViewController)
}

class ReauthenticateCodeValidationViewController: BaseViewController, UITextFieldDelegate {
    
    weak var flowDelegate: ReauthenticateCodeValidationFlowDelegate?
    
    // Those need to be set
    var phoneNumber: String!
    var validationToken: String!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet var inputFields: [UITextField]!
    @IBOutlet weak var continueButton: ConfirmationButton!
    
    private let authService = FirebaseAuthentication()
    private let userService = UserService()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        clearCodes()
        continueButton.set(active: false)
        
        for field in inputFields {
            field.addTextChangeObserver(item: self, selector: #selector(textFieldDidChange(_:)))
            field.delegate = self
        }
        
        subtitleLabel.attributedText = NSAttributedString.authenticationAttributes(text: "code.validation.subtitle".localized + phoneNumber, bolded: [phoneNumber], accentColor: UIColor.secondaryText)
        
        addBackButton(delegate: flowDelegate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputFields[0].becomeFirstResponder()
    }
    
    // MARK: Actions
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let code = getCode() else {
            return
        }
        
        validate(code: code)
    }
    
    @IBAction func resendPressed(_ sender: Any) {
        loading = true
        authService.validatePhoneNumber(number: phoneNumber) { (success, value, error) in
            self.loading = false
            
            guard success, let value = value else {
                return
            }
            
            self.validationToken = value
        }
    }
    
    // MARK: Text field callbacks
    
    @objc
    func textFieldDidChange(_ field: UITextField) {
        guard let currentIndex = inputFields.firstIndex(of: field) else {
            return
        }

        if let text = field.text,
           text.count == 1 {
            // Go to the next field
            let next = Int(currentIndex) + 1
            
            if next < inputFields.count {
                inputFields[next].becomeFirstResponder()
                
            } else {
                // Last field
                field.resignFirstResponder()
            }
            
        } else {
            // Go to previous
            let prev = Int(currentIndex) - 1
            if prev >= 0 {
                inputFields[prev].becomeFirstResponder()
            }
        }
        
        if let _ = getCode() {
            continueButton.set(active: true)
        } else {
            continueButton.set(active: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        
        if let currentIndex = inputFields.firstIndex(of: textField), currentIndex == 0, string.count == 6 {
            DispatchQueue.main.async {
                for i in 0..<6 {
                    let field = self.inputFields[i]
                    let letter = Array(string)[i]
                    
                    field.text = String(letter)
                }
                
                self.enableButtonIfNeeded()
            }
            
            return false
        }
        
        if string.count > 6 {
            return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        if count > 1 {
            // enter the text in the next field
            let next = getNextField(field: textField)
            next?.text = string
            next?.becomeFirstResponder()
        }
        
        enableButtonIfNeeded()
        
        return count <= 1
    }
    
    // MARK: Private methods
    
    private func enableButtonIfNeeded() {
        if let _ = getCode() {
            continueButton.set(active: true)
        } else {
            continueButton.set(active: false)
        }
    }
    
    private func getNextField(field: UITextField) -> UITextField? {
        guard let currentIndex = inputFields.firstIndex(of: field) else {
            return nil
        }
        
        
        // Go to the next field
        let next = Int(currentIndex) + 1
        
        if next < inputFields.count {
            return inputFields[next]
        }
        
        return nil
    }
    
    private func clearCodes() {
        for i in 0..<inputFields.count {
            inputFields[i].text = nil
        }
    }
    
    private func getCode() -> String? {
        var code = ""
        
        for field in inputFields {
            if let text = field.text {
                code += text
            }
        }
        
        if code.count == 6 {
            return code
        }
        
        return nil
    }
    
    private func validate(code: String) {
        loading = true
        
        authService.reauthenticate(verificationID: validationToken, code: code) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let token):
                self.userAuthenticated(token: token)
            }
        }
    }
    
    private func userAuthenticated(token: String) {
        handleToken(token)
        fetchCurrentUser()
    }
    
    private func handleToken(_ token: String) {
        Context.current.accessToken = token
    }
    
    private func fetchCurrentUser() {
        loading = true
        userService.getCurrentUser { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.flowDelegate?.reauthenticatePhoneCodeValidationSuccesfullyChanged(vc: self)
            }
        }
    }
}

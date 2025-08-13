//
//  ReauthenticatePhoneNumberViewController.swift
//  TimeStream
//
//  Created by appssemble on 15.07.2021.
//

import Foundation
import UIKit
import FlagKit

protocol ReauthenticatePhoneNumberFlowDelegate: BaseViewControllerFlowDelegate {
    func reauthenticatePhoneHasValidated(vc: ReauthenticatePhoneNumberViewController, phoneNumber: String, validationToken: String)
}

class ReauthenticatePhoneNumberViewController: BaseViewController,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var flowDelegate: ReauthenticatePhoneNumberFlowDelegate?
    
    private let authService = FirebaseAuthentication()
    
    @IBOutlet weak var numberField: UITextField!
    
    @IBOutlet weak var countryImageView: UIImageView!

    @IBOutlet weak var proceedButton: ConfirmationButton!
    @IBOutlet weak var prefixTextField: UITextField!
    
    private let countryPickerView = UIPickerView()
    private let countries = CountryCodes.values()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        numberField.addTextChangeObserver(item: self, selector: #selector(textFieldDidChange(_:)))
        
        prefixTextField.inputView = countryPickerView
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
        
        addBackButton(delegate: flowDelegate)
        proceedButton.set(active: false)
        
        let code = TelephonyHelper.getRegionCode()
        setCountry(code: code)
        
        addBackButton(delegate: flowDelegate)
    }
   
    // MARK: Actions

    @IBAction func pickPrefix(_ sender: Any) {
        prefixTextField.becomeFirstResponder()
    }
    
    @IBAction func proceed(_ sender: Any) {
        guard let number = phoneNumber() else {
            return
        }
        
        loading = true
        authService.validatePhoneNumber(number: number) { (success, id, error) in
            self.loading = false
            
            guard let id = id, success else {
                if let error = error as NSError?, error.code == 17010 {
                    
                    self.showAlert(message: "too.many.attempts".localized)
                    return
                }
                
                self.showGenericError()
                return
            }
            
            self.flowDelegate?.reauthenticatePhoneHasValidated(vc: self, phoneNumber: number, validationToken: id)
        }
    }
    
    // MARK: Picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = countries[row]
        
        return country.countryName
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        
        prefixTextField.text = "+" + country.dialCode
        setFlag(code: country.countryCode)
    }
    
    // MARK: Text field
    
    @objc
    func textFieldDidChange(_ field: UITextField) {
        proceedButton.set(active: phoneNumber() != nil)
    }
    
    // MARK: Private methods
    
    private func setFlag(code: String) {
        let flag = Flag(countryCode: code)
        countryImageView.image = flag?.image(style: .circle)
    }
    
    private func setCountry(code: String?) {
        if let code = code, let country = countries.first(where: {$0.countryCode == code}) {
            prefixTextField.text = "+" + country.dialCode
            setFlag(code: country.countryCode)
            
        } else {
            prefixTextField.text = "+44"
            setFlag(code: "GB")
        }
    }
    
    private func phoneNumber() -> String? {
        guard let prefix = prefixTextField.text, prefix.count > 1 else {
            return nil
        }
        
        guard let number = numberField.text, number.count > 5 else {
            return nil
        }
        
        return prefix + number
    }
}

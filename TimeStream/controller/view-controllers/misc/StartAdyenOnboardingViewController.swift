//
//  StartAdyenOnboardingViewController.swift
//  TimeStream
//
//  Created by appssemble on 28.03.2022.
//

import UIKit

protocol StartAdyenOnboardingViewControllerDelegate: AnyObject {
    func adyenOnboardingDetailsCollected(vc: UIViewController)
}


class StartAdyenOnboardingViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: StartAdyenOnboardingViewControllerDelegate?

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var proceedButton: ConfirmationButton!
    
    private let countryPickerView = UIPickerView()
    
    private let countries = CountryCodes.values()
    private var selectedCountry: CountryCodes.CountryWithCode?
    private let adyenPaymentsService = AdyenPaymentService()
    
    
    static func loadFromXib(delegate: StartAdyenOnboardingViewControllerDelegate) -> StartAdyenOnboardingViewController {
        let vc = StartAdyenOnboardingViewController(nibName: "StartAdyenOnboardingViewController", bundle: nil)
        vc.delegate = delegate
        
        return vc
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(selector: #selector(backPressed2))
        
        countryField.inputView = countryPickerView
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
        
        proceedButton.set(active: false)
        
        firstNameField.addTextChangeObserver(item: self, selector: #selector(enableButtonIfNeeded))
        lastNameField.addTextChangeObserver(item: self, selector: #selector(enableButtonIfNeeded))
        countryField.addTextChangeObserver(item: self, selector: #selector(enableButtonIfNeeded))
        emailField.addTextChangeObserver(item: self, selector: #selector(enableButtonIfNeeded))
        
        title = "payments.onboarding".localized
    }
    
    // MARK: Actions
    
    @objc
    private func backPressed2() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceed(_ sender: Any) {
        guard let firstName = firstNameField.text,
              firstName.count > 1,
              let lastName = lastNameField.text,
              lastName.count > 1,
              let email = emailField.text,
              isValidEmail(email),
              let country = selectedCountry else {

                  proceedButton.set(active: false)
                  return
              }

        loading = true
        adyenPaymentsService.startMerchantAccountCreation(email: email, firstName: firstName, lastName: lastName, countryCode: country.countryCode) { result in

            switch result {
            case .error:
                self.loading = false
                self.showGenericError()

            case .success(let user):
                Context.current.user = user

                self.loading = false
                self.delegate?.adyenOnboardingDetailsCollected(vc: self)
            }
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
        
        selectedCountry = country
        countryField.text = country.countryName
        enableButtonIfNeeded()
    }
    
    
    // MARK: Private methods
    
    @objc
    private func enableButtonIfNeeded() {
        guard let firstName = firstNameField.text,
              firstName.count > 1,
              let lastName = lastNameField.text,
              lastName.count > 1,
              let email = emailField.text,
              isValidEmail(email),
              selectedCountry != nil else {
                  
                  proceedButton.set(active: false)
                  return
              }
        
        proceedButton.set(active: true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
}

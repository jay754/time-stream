//
//  StartAdyenOnboardingViewController.swift
//  TimeStream
//
//  Created by appssemble on 28.03.2022.
//

import UIKit


class StartAdyenBusinessOnboardingViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: StartAdyenOnboardingViewControllerDelegate?

    @IBOutlet weak var businessCountryOfOriginField: UITextField!
    @IBOutlet weak var businessNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var proceedButton: ConfirmationButton!
    
    private let countryPickerView = UIPickerView()
    private let businessCountryPickerView = UIPickerView()
    
    private let countries = CountryCodes.values()
    private var businessSelectedCountry: CountryCodes.CountryWithCode?
    private let adyenPaymentsService = AdyenPaymentService()
    
    
    static func loadFromXib(delegate: StartAdyenOnboardingViewControllerDelegate) -> StartAdyenBusinessOnboardingViewController {
        let vc = StartAdyenBusinessOnboardingViewController(nibName: "StartAdyenBusinessOnboardingViewController", bundle: nil)
        vc.delegate = delegate
        
        return vc
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(selector: #selector(backPressed2))
        
        businessCountryOfOriginField.inputView = businessCountryPickerView
        businessCountryPickerView.dataSource = self
        businessCountryPickerView.delegate = self
        
        proceedButton.set(active: false)
        
        emailField.addTextChangeObserver(item: self, selector: #selector(enableButtonIfNeeded))
        
        title = "payments.onboarding".localized
    }
    
    // MARK: Actions
    
    @objc
    private func backPressed2() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceed(_ sender: Any) {
        guard let businessName = businessNameField.text,
              businessName.count > 1,
              let email = emailField.text,
              isValidEmail(email),
              let businessCountry = businessSelectedCountry else {

                  proceedButton.set(active: false)
                  return
              }

        loading = true
        adyenPaymentsService.startMerchantBusinessAccountCreation(email: email, businessName: businessName, businessCountryCode: businessCountry.countryCode) { result in

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
        
        
        if businessCountryPickerView === pickerView {
            businessSelectedCountry = country
            businessCountryOfOriginField.text = country.countryName
        }
        
        enableButtonIfNeeded()
    }
    
    
    // MARK: Private methods
    
    @objc
    private func enableButtonIfNeeded() {
        guard let email = emailField.text,
              isValidEmail(email),
              businessSelectedCountry != nil else {
                  
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

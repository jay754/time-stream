//
//  PaymentDetailsViewController.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit
import Stripe
import SafariServices

typealias CharitySelectionClosure = (_ charity: Charity) -> Void

protocol PaymentDetailsFlowDelegate: BaseViewControllerFlowDelegate {
    func paymentDetailsSelectCharity(vc: PaymentDetailsViewController, selection: @escaping CharitySelectionClosure, selectedCharity: Charity?)
}

private struct PaymentDetailsState {
    var addedCard = false
    var addedBank = false
    var pendingBank = true
    var donnationsAllowed = false
    var charitySelected = false
}

class PaymentDetailsViewController: BaseViewController {

    weak var flowDelegate: PaymentDetailsFlowDelegate?
    
    var shouldEnableCharity = false

    @IBOutlet weak var saveButton: ConfirmationButton!
    
    @IBOutlet weak var priceCurrency: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    
    @IBOutlet weak var addBankContainer: BorderedView!
    @IBOutlet weak var changeBankContainer: UIView!
    @IBOutlet weak var bankNameLabel: UILabel!
    
    @IBOutlet weak var donatedAmountContainer: UIView!
    @IBOutlet weak var addCharityContainer: BorderedView!
    @IBOutlet weak var changeCharityContainer: UIView!
    @IBOutlet weak var allowDonationsSwitch: UISwitch!
    @IBOutlet weak var donatedAmountTextField: UITextField!
    @IBOutlet weak var charityName: UILabel!
    @IBOutlet weak var chairtyDescription: UILabel!
    @IBOutlet weak var charityImageView: UIImageView!
    
    private var state = PaymentDetailsState()
    private var helper: AdyenPaymentHelper!
    private var selectedCharity: Charity?
    private let userService = UserService()
    private var shouldReload = true
    private var firstLoad = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = Context.current.user else {
            flowDelegate?.backButtonPressed(from: self)
            return
        }
        
        selectedCharity = user.charity
        
        addBackButton(delegate: flowDelegate)
        changeState()
        
        helper = AdyenPaymentHelper(vc: self)
        
        priceCurrency.isUserInteractionEnabled = false
        
        saveButton.set(active: false)
        
        donatedAmountTextField.addTextChangeObserver(item: self, selector: #selector(textChanged))
        
        priceLabel.attributedPlaceholder = NSAttributedString.placeholderText(text: "payment.details.price".localized, light: ["payment.details.price.min".localized])
        priceLabel.addTextChangeObserver(item: self, selector: #selector(textChanged))
        
        if shouldEnableCharity {
            state.donnationsAllowed = true
            allowDonationsSwitch.isOn = true
            changeState()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !shouldReload {
            shouldReload = !shouldReload
            
        } else {
            populate()
            loadAccount()
        }
        
        if shouldEnableCharity && firstLoad {
            firstLoad = false
            selectCharity(self)
        }
    }
    
    // MARK: Actions
    
    @IBAction func selectCharity(_ sender: Any) {
        flowDelegate?.paymentDetailsSelectCharity(vc: self, selection: {[weak self] charity in
            self?.shouldEnableCharity = false
            self?.selectedCharity = charity
            self?.state.charitySelected = true
            self?.changeState()
            self?.shouldReload = false
        }, selectedCharity: self.selectedCharity)
    }
    
    @IBAction func allowDonationChanged(_ sender: Any) {
        state.donnationsAllowed = allowDonationsSwitch.isOn
        if allowDonationsSwitch.isOn == false {
            disableCharities()
            changeState()
        } else {
            guard let user = Context.current.user else {
                return
            }
            
            if let percentage = user.donationPercentage, percentage != 0 {
                donatedAmountTextField.text = "\(percentage)"
            } else {
                donatedAmountTextField.text = nil
            }
            
            selectedCharity = user.charity
            state.charitySelected = selectedCharity != nil
            changeState()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let new = newUser() else {
            return
        }
        
        if let price = new.price,
           price <= 2 {
            showAlert(title: "price".localized, message: "price.wrong.value".localized)
            return
        }
        
        loading = true
        userService.updateUser(user: new, photo: nil) { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let user):
                Context.current.user = user
                self.flowDelegate?.backButtonPressed(from: self)
            }
        }
    }
    
    // MARK: Text field
    
    @objc
    private func textChanged() {
        changeState()
    }
    
    // MARK: Private methods
    
    private func disableCharities() {
        allowDonationsSwitch.isOn = false
        donatedAmountTextField.text = nil
        state.charitySelected = false
        selectedCharity = nil
        state.donnationsAllowed = false
    }
    
    private func loadAccount() {
        loading = true
        helper.hasBankAccountAdded { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let hasBank):
                self.state.addedBank = hasBank.accountValid || hasBank.pendingAuthorization
                self.state.pendingBank = hasBank.pendingAuthorization
                self.changeState()
            }
        }
    }
    
    private func changeState() {
        addBankContainer.isHidden = state.addedBank
        changeBankContainer.isHidden = !state.addedBank
        
        allowDonationsSwitch.isOn = state.donnationsAllowed

        if state.pendingBank {
            bankNameLabel.text = "bank.account.pending".localized
        } else {
            bankNameLabel.text = "bank.account.set".localized
        }
        
        if state.donnationsAllowed {
            donatedAmountContainer.isHidden = false
        
            addCharityContainer.isHidden = state.charitySelected
            changeCharityContainer.isHidden = !state.charitySelected
            
        } else {
            donatedAmountContainer.isHidden = true
            addCharityContainer.isHidden = true
            changeCharityContainer.isHidden = true
        }
        
        if let charity = selectedCharity {
            charityName.text = charity.title
            chairtyDescription.text = charity.subtitle
            charityImageView.setImage(url: charity.imageURL)
        }
        
        saveButton.set(active: newUser() != nil)
    }
    
    private func populate() {
        guard let user = Context.current.user else {
            return
        }
        
        priceCurrency.text = user.currency.sign()
        if let price = user.price {
            priceLabel.text = price.priceFromCents()
        } else {
            priceLabel.text = nil
        }
        
        if let percentage = user.donationPercentage, percentage != 0 {
            donatedAmountTextField.text = "\(percentage)"
        } else {
            donatedAmountTextField.text = nil
        }
        
        selectedCharity = user.charity
        state.charitySelected = selectedCharity != nil
        
        state.donnationsAllowed = user.donationsAllowed
        if shouldEnableCharity {
            state.donnationsAllowed = true
        }
        
        changeState()
    }
    
    private func newUser() -> User? {
        guard let user = Context.current.user else {
            return nil
        }
        
        let priceDifferent = differentPrice()
        let charityDifferent = differentCharity()
        let percentageDifferent = donationPercentageDifferent()
        let switchDifferent = (allowDonationsSwitch.isOn != user.donationsAllowed)
        
        var price: Int? = user.price
        if let newPrice = priceDifferent {
            price = newPrice
        }
        
        var charity = charityDifferent ?? user.charity
        let everythingSelected = (priceDifferent != nil) || ((percentageDifferent != nil) && (price != nil) && (charity != nil))
        
        var percentage = percentageDifferent ?? user.donationPercentage
        
        var disableCharity = false
        if switchDifferent && !allowDonationsSwitch.isOn {
            // Disable charity
            disableCharity = true
        }
        
        let charityChanged = (charityDifferent != nil || (percentageDifferent != nil))
        
        if ((priceDifferent != nil || charityChanged) && everythingSelected) || disableCharity {
            let newPrice = priceDifferent ?? user.price
            
            if charityChanged && charity == nil {
                return nil
            }
            
            if disableCharity {
                // Disable donations
                percentage = 0
                charity = nil
            }
            
            var newUser = User(id: user.id, firebaseID: user.firebaseID, name: user.name, phoneNumber: user.phoneNumber, photoURL: user.photoURL, bio: user.bio, followers: user.followers, following: user.following, tipsEnabled: user.tipsEnabled, availableInteractions: user.availableInteractions, createdAt: user.createdAt, donationsAllowed: user.donationsAllowed, price: newPrice, charity: charity, currency: user.currency, expertise: user.expertise, paymentDetailsCollected: user.paymentDetailsCollected, followingIDs: user.followingIDs, fcmToken: user.fcmToken, donationPercentage: percentage, username: user.username)
            newUser.categoriesOfInterest = user.categoriesOfInterest
            
            return newUser
        }
    
        return nil
    }
    
    private func differentPrice() -> Int? {
        guard let user = Context.current.user else {
            return nil
        }
        
        guard let pricing = priceLabel.text,
              let value = Int(pricing) else {
            return nil
        }
        
        let priceDifferent = user.price?.priceFromCents() != priceLabel.text
        if priceDifferent {
            if value < 2 {
                return nil
            }
            
            return value.centsPrice()
        }
        
        return nil
    }
    
    private func differentCharity() -> Charity? {
        guard let user = Context.current.user else {
            return nil
        }
        
        let charityDifferent = user.charity?.id != selectedCharity?.id
        if charityDifferent || (user.charity == nil && selectedCharity == nil) {
            return selectedCharity
        }
        
        return nil
    }
    
    private func donationPercentageDifferent() -> Int? {
        guard let user = Context.current.user else {
            return nil
        }
        
        if let percentage = user.donationPercentage {
            let donationPercentageDifferent = "\(percentage)" != donatedAmountTextField.text
            
            if !donationPercentageDifferent {
                return nil
            }
        }

        if let donation = donatedAmountTextField.text,
           let donationValue = Int(donation),
           donationValue >= 1,
           donationValue <= 100 {
            
            return donationValue
        }
        
        return nil
    }
}


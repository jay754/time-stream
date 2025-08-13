//
//  CurrentUserProfileActionsView.swift
//  TimeStream
//
//  Created by appssemble on 10.02.2022.
//

import UIKit

protocol CurrentUserProfileActionsDelegate: AnyObject {
    func currentUserActionsSetPrice(view: CurrentUserProfileActionsView)
    func currentUserActionsSetAvailability(view: CurrentUserProfileActionsView)
    func currentUserActionsSetCharity(view: CurrentUserProfileActionsView)
    func currentUserActionsSetBankAccount(view: CurrentUserProfileActionsView)
}

class CurrentUserProfileActionsView: UIView {
    
    weak var delegate: CurrentUserProfileActionsDelegate?

    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var availability: UILabel!
    @IBOutlet weak var charity: UILabel!
    @IBOutlet weak var startEarning: UILabel!

    
    func populate(user: User, bankAccount: BankAccountSetup?) {
        if let _ = user.price {
            price.text = user.formattedPrice + "/min"
        } else {
            price.text = "set".localized
        }
        
        if user.availableInteractions > 0 {
            availability.text = "enabled".localized
        } else {
            availability.text = "disabled".localized
        }
        
        if let uc = user.charity, let percentage = user.donationPercentage {
            charity.text = "\(percentage)%"// + uc.title
        } else {
            charity.text = "select".localized
        }
        
        if let bankAccount = bankAccount,
            bankAccount.accountValid && bankAccount.pendingAuthorization == false {
            startEarning.text = "details".localized
        } else {
            startEarning.text = "start".localized
        }
    }
    
    // MARK: Actions
    
    @IBAction func changePrice(_ sender: Any) {
        delegate?.currentUserActionsSetPrice(view: self)
    }
    
    @IBAction func changeAvailability(_ sender: Any) {
        delegate?.currentUserActionsSetAvailability(view: self)
    }
    
    @IBAction func selectCharity(_ sender: Any) {
        delegate?.currentUserActionsSetCharity(view: self)
    }
    
    @IBAction func bankAccount(_ sender: Any) {
        delegate?.currentUserActionsSetBankAccount(view: self)
    }
}

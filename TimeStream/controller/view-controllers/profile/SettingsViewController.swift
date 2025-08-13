//
//  SettingsViewController.swift
//  TimeStream
//
//  Updated by Pantelis Grigoriou 14 Sep 2023.
//

import UIKit
import MessageUI
import EggRating


protocol SettingsFlowDelegate: BaseViewControllerFlowDelegate {
    func settingsGoToWeb(vc: SettingsViewController, title: String, url: URL)
    func settingGoToPayment(vc: SettingsViewController)
    func settingsDidLogOut(vc: SettingsViewController)
}

struct AppLinks {
    static let termsAndConditions = URL(string: "https://www.time.stream/terms")!
    static let privacyPolicy = URL(string: "https://www.time.stream/privacy")!
    static let prohibitedActivities = URL(string: "https://www.time.stream/prohibited")!
}

class SettingsViewController: BaseViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    weak var flowDelegate: SettingsFlowDelegate?
    
    private let dynamicLinkHelper = DynamicLinkHelper()
    private let authService = FirebaseAuthentication()
    private let userService = UserService()

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(delegate: flowDelegate)
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "version".localized + " " + appVersion
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppearanceHelper.configureNavigationBar()
    }
    
    // MARK: Actions

    @IBAction func notifications(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
        })
    }
    
    @IBAction func payment(_ sender: Any) {
        flowDelegate?.settingGoToPayment(vc: self)
    }
    
    @IBAction func shareWithFriends(_ sender: Any) {
        dynamicLinkHelper.showShareAppSheet(from: self)
    }
    
    @IBAction func termsAndConditions(_ sender: Any) {
        flowDelegate?.settingsGoToWeb(vc: self, title: "terms".localized, url: AppLinks.termsAndConditions)
    }
    
    @IBAction func feedback(_ sender: Any) {
        EggRating.delegate = self
        EggRating.shouldShowThankYouAlertController = false
        EggRating.promptRateUs(in: self)
    }
    
    @IBAction func contactUs(_ sender: Any) {
        sendMail(title: "iOS TIME app feedback", recipient: "info@time.stream")
    }
    
    @IBAction func privacy(_ sender: Any) {
        flowDelegate?.settingsGoToWeb(vc: self, title: "privacy".localized, url: AppLinks.privacyPolicy)
    }
    
    @IBAction func logout(_ sender: Any) {
        makeLogout()
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alertController = UIAlertController(title: "delete".localized, message: "are.you.sure.delete".localized, preferredStyle: .alert)
        let action = UIAlertAction(title: "delete".localized, style: .destructive) { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
            
            self.loading = true
            self.userService.deleteUser { (_) in
                self.makeLogout()
            }
        }
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
        })
        
        alertController.addAction(action)
        alertController.addAction(cancel)
        alertController.showOnANewWindow()
    }
    
    private func makeLogout() {
        loading = true
        userService.logout { (_) in
            self.authService.signOut {
                self.loading = false

                Context.current.clearCurrentUserData()
                self.flowDelegate?.settingsDidLogOut(vc: self)
            }
        }
    }
    
    fileprivate func sendMail(title: String, recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.setToRecipients([recipient])
            mailComposerVC.setSubject(title)
            mailComposerVC.mailComposeDelegate = self
            
            present(mailComposerVC, animated: true, completion: nil)
            
        } else {
            showAlert(message: "no.email.set".localized + "info@time.stream.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}


extension SettingsViewController: EggRatingDelegate {
    
    func didRate(rating: Double) {
        presentedViewController?.dismiss(animated: false, completion: nil)
        
        if rating < 3.5 {
            sendMail(title: "Help up improve TIME with your suggestions!", recipient: "info@time.stream")
        }
    }
    
    func didRateOnAppStore() {
    }
    
    func didIgnoreToRate() {
    }
    
    func didIgnoreToRateOnAppStore() {
    }
    
    func didDissmissThankYouDialog() {
    }
}

//
//  AdyenPaymentHelper.swift
//  TimeStream
//
//  Created by appssemble on 16.03.2022.
//

import UIKit
import Adyen

enum PaymentStatus {
    case canceled
    case successfull(paymentIntent: PaymentIntent)
    case failed
}

typealias PaymentClosure = (_ status: PaymentStatus) -> Void

fileprivate enum AdyenPaymentHelperType {
    case request(Int)
    case tip(Int, Int, Currency)
}

class AdyenPaymentHelper: NSObject {
    
    private struct Constants {
        static let returnURL = "https://appssemble.com/time-return"
        static let refreshURL = "https://appssemble.com/time-reauth"
    }
    
    private let navigationController = UINavigationController()
    private let service = AdyenPaymentService()
    private var onboardingCompletionClosure: EmptyClosure?
    private var paymentCompletedClosure: PaymentClosure?
    private var firstSelect = false
    
    private var fromVC: BaseViewController!
    
#if DEBUG
    private let apiContext = APIContext(environment: Environment.test, clientKey: "test_WZ36O7R4IZDDLNPXXTWM5Q2G5M2RBMLC")
#else
    private let apiContext = APIContext(environment: Environment.live, clientKey: "live_OEGOVBIJ4VEONLKEGXNVETQLIM4JHQ7I")
#endif
    
    private var dropInComponent: DropInComponent?
    private var webView: AdyenWebViewController?
    
    private var type: AdyenPaymentHelperType!
    
    init(vc: BaseViewController) {
        super.init()
        
        fromVC = vc
    }
    
    // MARK: Methods
    
    func startPaymentSheet(creatorID: Int, completion: @escaping PaymentClosure) {
        paymentCompletedClosure = completion
        type = .request(creatorID)
        
        service.getPaymentDetailsRequest(creatorID: creatorID) { result in
            switch result {
            case .error:
                completion(.failed)
                
            case .success(let paymentMethods):
                self.startPaymentSheetUI(methods: paymentMethods)
            }
        }
    }
    
    func startTipPaymentSheet(creatorID: Int, amount: Int, completion: @escaping PaymentClosure) {
        paymentCompletedClosure = completion
        type = .tip(creatorID, amount, Currency.current())
        
        fromVC.loading = true
        service.getPaymentDetailsTip(creatorID: creatorID, amount: amount, currency: Currency.current()) { result in
            switch result {
            case .error:
                completion(.failed)
                
            case .success(let paymentMethods):
                self.startPaymentSheetUI(methods: paymentMethods)
            }
        }
    }
    
    func openOnboardingScreen(completiton: EmptyClosure?) {
        guard let user = Context.current.user else {
            completiton?()
            fromVC.showGenericError()
            return
        }
        
        onboardingCompletionClosure = completiton
        
        if user.paymentDetailsCollected {
            // Go to onboarding
            startAdyenOnboarding()
        } else {
            // Go to collect details
            startAdyenDataCollection()
        }
    }
    
    func hasBankAccountAdded(completion: @escaping BankAccountSetupClosure) {
        service.hasBankAccountSetUp(completion: completion)
    }
    
    // MARK: Private methods
    
    private func startAdyenOnboarding() {
        service.getOnboardingURL(completion: { result in
            switch result {
            case .error:
//                self.fromVC.showGenericError()
                self.onboardingCompletionClosure?()
                self.onboardingCompletionClosure = nil
                
                self.fromVC.showAlert(message: "payments.onboarding.link.not.ready".localized)
                
            case .success(let url):
                self.webView = AdyenWebViewController.loadFromXib(url: url, delegate: self)
                self.fromVC.present(self.webView!, animated: true, completion: nil)
//                UIApplication.shared.open(url)
            }
        })
    }
    
    private func startAdyenDataCollection() {
        let alertController = UIAlertController(title: "data.collection".localized, message: "data.collection.question".localized, preferredStyle: .alert)
        
        let individual = UIAlertAction(title: "data.collection.invidual".localized, style: .default) { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
            
            self.startIndividualDataCollection()
        }
        
        let business = UIAlertAction(title: "data.collection.business".localized, style: .default) { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
            
            self.startBusinessDataCollection()
        }
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_) in
            // remove the window
            alertController.xxx_window?.isHidden = true
            alertController.xxx_window = nil
        })
        
        alertController.addAction(individual)
        alertController.addAction(business)
        alertController.addAction(cancel)
        alertController.showOnANewWindow()
    }
    
    private func startIndividualDataCollection() {
        let nav = UINavigationController()
        let adyenDataCollection = StartAdyenOnboardingViewController.loadFromXib(delegate: self)
        nav.viewControllers = [adyenDataCollection]
        nav.modalPresentationStyle = .fullScreen

        fromVC.present(nav, animated: true, completion: nil)
    }
    
    private func startBusinessDataCollection() {
        let nav = UINavigationController()
        let adyenDataCollection = StartAdyenBusinessOnboardingViewController.loadFromXib(delegate: self)
        nav.viewControllers = [adyenDataCollection]
        nav.modalPresentationStyle = .fullScreen

        fromVC.present(nav, animated: true, completion: nil)
    }
    
    private func startPaymentSheetUI(methods: AdyenPaymentMethodsResponse) {
        let configuration = DropInComponent.Configuration(apiContext: apiContext)
        
        let dropInComponent = DropInComponent(paymentMethods: methods.methods, configuration: configuration)
        dropInComponent.delegate = self
         
        // Keep the Drop-in instance to avoid it being destroyed after the function is executed.
        self.dropInComponent = dropInComponent
         
        configuration.payment = Adyen.Payment(amount: Amount(value: methods.amountCents, currencyCode: methods.currency.rawValue), countryCode: TelephonyHelper.getRegionCode())
        fromVC.present(dropInComponent.viewController, animated: true)
    }
}
                                 
extension AdyenPaymentHelper: AdyenWebViewControllerDelegate {
    func adyenWebViewHasFinished(vc: AdyenWebViewController) {
        vc.dismiss(animated: true, completion: nil)
        onboardingCompletionClosure?()
        onboardingCompletionClosure = nil
    }
}

extension AdyenPaymentHelper: DropInComponentDelegate {
    func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
        dismissComponent(dropInComponent: component)
        
        switch type {
        case .request(let creatorID):
            handleDidProvideActionsRequest(creatorID: creatorID, data: data, component: component)
            
        case .tip(let creatorID, let amount, let currency):
            handleDidProvideActionsTip(creatorID: creatorID, amount: amount, currency: currency, data: data, component: component)
            
        default:
            dismissComponent(dropInComponent: component)
            paymentCompletedClosure?(.failed)
        }
    }
    
    func didComplete(from component: DropInComponent) {
        dismissComponent(dropInComponent: component)
    }
    
    func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent) {
        switch type {
        case .tip(let creatorID, let amount, let currency):
            handleDidSubmitTip(creatorID: creatorID, amount: amount, currency: currency, data: data, component: component)
            
        case .request(let creatorID):
            handleDidSubmitRequest(creatorID: creatorID, data: data, component: component)
            
        default:
            dismissComponent(dropInComponent: component)
            paymentCompletedClosure?(.failed)
        }
    }
    
    func didFail(with error: Error, from component: DropInComponent) {
        dismissComponent(dropInComponent: component)
        
        if let error = error as? Adyen.ComponentError,
           error == .cancelled {
            
            paymentCompletedClosure?(.canceled)
            return
        }
        
        paymentCompletedClosure?(.failed)
    }
    
    func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent) {
        dismissComponent(dropInComponent: dropInComponent)
        paymentCompletedClosure?(.canceled)
    }
    
    // MARK: Private
    
    private func handleDidProvideActionsRequest(creatorID: Int, data: ActionComponentData, component: DropInComponent) {
        service.submitActionResponseRequest(creatorID: creatorID, data: data) { result in
            self.handleDidProvideActionsResponse(component: component, result: result)
        }
    }
    
    private func handleDidProvideActionsTip(creatorID: Int, amount: Int, currency: Currency, data: ActionComponentData, component: DropInComponent) {
        
        service.submitActionResponseTip(creatorID: creatorID, amount: amount, currency: currency, data: data) { result in
            self.handleDidProvideActionsResponse(component: component, result: result)
        }
    }
    
    private func handleDidProvideActionsResponse(component: DropInComponent, result: Result<AdyenPaymentAnswerResponse>) {
        switch result {
        case .success(let response):
            if response.success == true, let intent = response.paymentIntent {
                // ALL GOOD
                self.handleSuccess(component: component, intent: intent)
                
                return
            } else if let action = response.action {
                component.handle(action)
                return
            }
            
            fallthrough
        case .error:
            self.dismissComponent(dropInComponent: component)
            self.paymentCompletedClosure?(.failed)
        }
    }
    
    private func dismissComponent(dropInComponent: DropInComponent) {
        dropInComponent.viewController.dismiss(animated: true, completion: nil)
    }
    
    private func handleSuccess(component: DropInComponent, intent: PaymentIntent) {
        self.dismissComponent(dropInComponent: component)
        self.paymentCompletedClosure?(.successfull(paymentIntent: intent))
    }
    
    private func handleDidSubmitRequest(creatorID: Int, data: PaymentComponentData, component: DropInComponent) {
        service.submitPaymentRequest(creatorID: creatorID, method: data.paymentMethod, storeCard: data.storePaymentMethod) { result in
            self.handleDidSubmitResponse(result: result, component: component)
        }
    }
    
    private func handleDidSubmitTip(creatorID: Int, amount: Int, currency: Currency, data: PaymentComponentData, component: DropInComponent) {
    
        service.submitPaymentTip(creatorID: creatorID, amount: amount, currency: currency, method: data.paymentMethod, storeCard: data.storePaymentMethod) { result in
            self.handleDidSubmitResponse(result: result, component: component)
        }
    }
    
    private func handleDidSubmitResponse(result: Result<AdyenPaymentActionResponse?>, component: DropInComponent) {
        switch result {
        case .error:
            self.dismissComponent(dropInComponent: component)
            self.paymentCompletedClosure?(.failed)
        
        case.success(let response):
            switch response {
            case .action(let action):
                component.handle(action)
                
            case .intent(let intent):
                self.handleSuccess(component: component, intent: intent)
                
            case .none:
                self.dismissComponent(dropInComponent: component)
                self.paymentCompletedClosure?(.failed)
            }
        }
    }
}

extension AdyenPaymentHelper: StartAdyenOnboardingViewControllerDelegate {
    func adyenOnboardingDetailsCollected(vc: UIViewController) {
        vc.navigationController?.dismiss(animated: true, completion: nil)
        onboardingCompletionClosure?()
        onboardingCompletionClosure = nil
        
        // Do nothing
//        startAdyenOnboarding()
    }
}
                                 
                                 


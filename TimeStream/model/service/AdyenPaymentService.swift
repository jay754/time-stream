//
//  AdyenPaymentService.swift
//  TimeStream
//
//  Created by appssemble on 16.03.2022.
//

import Foundation
import Adyen

typealias DictionaryClosure = (_ result: Result<[String: Any]>) -> Void
typealias BoolClosure = (_ result: Result<Bool>) -> Void
typealias NormalURLClosure = (_ result: Result<URL>) -> Void
typealias PaymentIntentClosure = (_ result: Result<PaymentIntent>) -> Void

typealias EarnedAmount = (amountCents: Int, currency: Currency)
typealias EarnedClosure = (_ result: Result<EarnedAmount>) -> Void

typealias PaymentsClosure = (_ result: Result<[Payment]>) -> Void

typealias BankAccountSetup = (accountValid: Bool, pendingAuthorization: Bool)
typealias BankAccountSetupClosure = (_ result: Result<BankAccountSetup>) -> Void

extension Encodable {
  fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
    try container.encode(self)
  }
}

internal struct AnyEncodable : Encodable {
  var value: Encodable
  init(_ value: Encodable) {
    self.value = value
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try value.encode(to: &container)
  }
}

typealias AdyenPaymentsMethodsClosure = (_ result: Result<AdyenPaymentMethodsResponse>) -> Void
typealias AdyenActionClosure = (_ result: Result<AdyenPaymentActionResponse?>) -> Void
typealias AdyenActionResponseClosure = (_ result: Result<AdyenPaymentAnswerResponse>) -> Void

typealias SimpleURLClosure = (_ result: Result<URL>) -> Void


class AdyenPaymentService {
    
    private struct Constants {
        static let payments = "payments/"
        
        static let paymentMethodsRequest = payments + "adyen_payment_methods_request"
        static let paymentMethodsTip = payments + "adyen_payment_methods_tip"
        
        static let authorizePaymentRequest = payments + "adyen_auth_payment_request"
        static let authorizePaymentTip = payments + "adyen_auth_payment_tip"
        
        static let actionDataRequest = payments + "adyen_action_data_request"
        static let actionDataTip = payments + "adyen_action_data_tip"
        
        static let startMerchantAccountCreation = payments + "adyen_start_merchant_account_creation"
        static let startMerchantBusinessAccountCreation = payments + "adyen_start_business_merchant_account_creation"
        static let onboardingURL = payments + "adyen_get_onboarding_url"
        static let hasBankAccountSetUp = payments + "adyen_has_bank_account_set_up"
    }
    
    private let service = ServiceHelper()
    private let mapper = PaymentServiceMapper()
    private let userMapper = UserMapper()
    
    // MARK: Methods
    
    func getPaymentDetailsRequest(creatorID: Int, completion: @escaping AdyenPaymentsMethodsClosure) {
        handlePaymentDetails(path: Constants.paymentMethodsRequest, data: mapper.IDParam(id: creatorID), completion: completion)
    }
    
    func getPaymentDetailsTip(creatorID: Int, amount: Int, currency: Currency, completion: @escaping AdyenPaymentsMethodsClosure) {
        handlePaymentDetails(path: Constants.paymentMethodsTip, data: mapper.adyenMapPaymentMethods(creatorID: creatorID, amount: amount, currency: currency), completion: completion)
    }
    
    func submitPaymentRequest(creatorID: Int, method: PaymentMethodDetails, storeCard: Bool, completion: @escaping AdyenActionClosure) {
        
        handleSubmitPayment(path: Constants.authorizePaymentRequest, data: mapper.adyenMapPaymentMethod(paymentMethod: method, storeCard: storeCard, creatorID: creatorID), completion: completion)
    }
    
    func submitPaymentTip(creatorID: Int, amount: Int, currency: Currency, method: PaymentMethodDetails, storeCard: Bool, completion: @escaping AdyenActionClosure) {
        
        handleSubmitPayment(path: Constants.authorizePaymentTip, data: mapper.adyenMapPaymentMethodTips(paymentMethod: method, amount: amount, currency: currency, storeCard: storeCard, creatorID: creatorID), completion: completion)
    }
    
    func submitActionResponseRequest(creatorID: Int, data: ActionComponentData, completion: @escaping AdyenActionResponseClosure) {
        handleSubmitActionResponse(path: Constants.actionDataRequest, data: mapper.adyenMapActionData(data: data, creatorID: creatorID), completion: completion)
    }
    
    func submitActionResponseTip(creatorID: Int, amount: Int, currency: Currency, data: ActionComponentData, completion: @escaping AdyenActionResponseClosure) {
        
        handleSubmitActionResponse(path: Constants.actionDataTip, data: mapper.adyenMapTipActionData(data: data, creatorID: creatorID, amount: amount, currency: currency), completion: completion)
    }
    
    func hasBankAccountSetUp(completion: @escaping BankAccountSetupClosure) {
        service.GET(path: Constants.hasBankAccountSetUp, data: nil) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let hasPayment = self.mapper.mapResponseFromHasBankAccount(dict: dict) else {
                    completion(.error(nil))
                    return
                }
                
                completion(.success(hasPayment))
            }
        }
    }
    
    func startMerchantAccountCreation(email: String, firstName: String, lastName: String, countryCode: String, completion: @escaping UserClosure) {
        
        service.POST(path: Constants.startMerchantAccountCreation, data: mapper.startAdyenAccountCreation(firstName: firstName, lastName: lastName, email: email, countryCode: countryCode)) { response in
            
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let user = self.userMapper.mapUserFromAuthResponse(dict: dict) else {
                    completion(.error(nil))
                    return
                }
                
                completion(.success(user))
            }
        }
    }
    
    func startMerchantBusinessAccountCreation(email: String, businessName: String, businessCountryCode: String, completion: @escaping UserClosure) {
        
        service.POST(path: Constants.startMerchantBusinessAccountCreation, data: mapper.startAdyenBusinessAccountCreation(email: email, businessName: businessName, businessCountryCode: businessCountryCode)) { response in
            
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let user = self.userMapper.mapUserFromAuthResponse(dict: dict) else {
                    completion(.error(nil))
                    return
                }
                
                completion(.success(user))
            }
        }
    }
    
    func getOnboardingURL(completion: @escaping SimpleURLClosure) {
        service.GET(path: Constants.onboardingURL, data: nil) { response in
            switch response {
            case .success(let dict):
                if let url = self.mapper.mapURL(dict: dict) {
                    completion(.success(url))
                    return
                }
                
                fallthrough
                
            case .error:
                completion(.error(nil))
                            
            }
        }
    }
    
    // MARK: Private methods
    
    private func handleSubmitPayment(path: String, data: [String: Any], completion: @escaping AdyenActionClosure) {
        service.POST(path: path, data: data) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                if let action = self.mapper.adyenMapActionsFromResponse(dict: dict) {
                    completion(.success(action))
                    
                    return
                }
                
                completion(.error(nil))
            }
        }
    }
    
    private func handlePaymentDetails(path: String, data: [String: Any], completion: @escaping AdyenPaymentsMethodsClosure) {
        service.GET(path: path, data: data) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                if let methods = self.mapper.adyenMapPaymentMethodsResponse(dict: dict) {
                    completion(.success(methods))
                    
                    return
                }
                
                completion(.error(nil))
            }
        }
    }
    
    private func handleSubmitActionResponse(path: String, data: [String: Any], completion: @escaping AdyenActionResponseClosure) {
        service.POST(path: path, data: data) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                if let action = self.mapper.adyenMapActionDataResponse(dict: dict) {
                    completion(.success(action))
                    
                    return
                }
                
                completion(.error(nil))
            }
        }
    }
}

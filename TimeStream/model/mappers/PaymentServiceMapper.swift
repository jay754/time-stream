//
//  PaymentServiceMapper.swift
//  TimeStream
//
//  Created by appssemble on 04.09.2021.
//

import Foundation
import Adyen

class PaymentServiceMapper {
    
    private struct Constants {
        static let id = "id"
        static let apiVersion = "api_version"
        static let lastFourDigits = "last_four_digts"
        static let paymentMethodID = "payment_method_id"
        
        static let hasPaymentMethod = "has_payment_method"
        static let accountIsSet = "account_is_set"
        static let pendingVerification = "pending_verification"
        static let url = "url"
        
        static let customerID = "customer_id"
        static let clientSecret = "client_secret"
        static let ephemeralKey = "ephemeral_key"
        static let paymentReference = "payment_reference"
        static let amount = "amount"
        
        static let currency = "currency"
        
        static let payments = "payments"
        static let earnedCents = "earned_cents"
        static let donatedCents = "donated_cents"
        static let from = "from"
        static let paymentType = "payment_type"
        static let createdAt = "created_at"
        
        static let currencyCode = "currency_code"
        
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let email = "email"
        static let countryCode = "country_code"
        
        static let redirectURL = "redirect_url"
        static let selectedPaymentMethod = "selected_payment_method"
        static let storeCard = "store_card"
        static let actionData = "action_data"
        static let paymentData = "payment_data"
        
        static let action = "action"
        static let success = "success"
        static let response = "response"
        static let paymentIntent = "payment_intent"
        
        static let businessName = "business_name"
        static let businessCountryCode = "business_country_code"
    }
    
    private let userMapper = UserMapper()
    
    // MARK: Methods
    
    func adyenMapPaymentMethod(paymentMethod: PaymentMethodDetails, storeCard: Bool, creatorID: Int) -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(AnyEncodable(paymentMethod))
            let pmJson = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]

            return [Constants.selectedPaymentMethod: pmJson,
                    Constants.storeCard: storeCard,
                    Constants.id: creatorID]
            
        } catch (let error) {
            print(error)
        }
        
        return [:]
    }
    
    func adyenMapPaymentMethodTips(paymentMethod: PaymentMethodDetails, amount: Int, currency: Currency, storeCard: Bool, creatorID: Int) -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(AnyEncodable(paymentMethod))
            let pmJson = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]

            return [Constants.selectedPaymentMethod: pmJson,
                    Constants.storeCard: storeCard,
                    Constants.id: creatorID,
                    Constants.amount: "\(amount)",
                    Constants.currencyCode: currency.rawValue]
            
        } catch (let error) {
            print(error)
        }
        
        return [:]
    }
    
    func adyenMapActionData(data: ActionComponentData, creatorID: Int) -> [String: Any] {
        do {
            let data2 = try JSONEncoder().encode(AnyEncodable(data.details))
            let json = try JSONSerialization.jsonObject(with: data2, options: .mutableContainers) as? [String:Any]

            return [Constants.actionData: json,
                    Constants.paymentData: data.paymentData,
                    Constants.id: creatorID]
            
        } catch (let error) {
            print(error)
        }
        
        return [:]
    }
    
    func adyenMapTipActionData(data: ActionComponentData, creatorID: Int, amount: Int, currency: Currency) -> [String: Any] {
        do {
            let data2 = try JSONEncoder().encode(AnyEncodable(data.details))
            let json = try JSONSerialization.jsonObject(with: data2, options: .mutableContainers) as? [String:Any]

            return [Constants.actionData: json,
                    Constants.paymentData: data.paymentData,
                    Constants.id: creatorID,
                    Constants.amount: "\(amount)",
                    Constants.currencyCode: currency.rawValue]
            
        } catch (let error) {
            print(error)
        }
        
        return [:]
    }

    func adyenMapPaymentMethodsResponse(dict: [String: Any]) -> AdyenPaymentMethodsResponse? {
        guard let currencyStr = dict[Constants.currency] as? String,
              let currency = Currency(rawValue: currencyStr),
              let response = dict[Constants.response] as? [String: Any],
              let amountCents = dict[Constants.amount] as? Int else {
                  return nil
              }
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: jsonData)
            return AdyenPaymentMethodsResponse(methods: paymentMethods, amountCents: amountCents, currency: currency)
            
        } catch { }
        
        return nil
    }
    
    func adyenMapActionsFromResponse(dict: [String: Any]) -> AdyenPaymentActionResponse? {
        // Only one of them can be valid
        if let paymentIntentDict = dict[Constants.paymentIntent] as? [String: Any],
           let intent = mapPaymentIntent(dict: paymentIntentDict) {
            
            return AdyenPaymentActionResponse.intent(intent)
        }
        
        do {
            if let actionDict = dict[Constants.action] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: actionDict, options: .prettyPrinted)
                let action = try JSONDecoder().decode(Action.self, from: jsonData)
                
                return AdyenPaymentActionResponse.action(action)
            }
            
        } catch { }

        return nil
    }
    
    func adyenMapActionDataResponse(dict: [String: Any]) -> AdyenPaymentAnswerResponse? {
        guard let success = dict[Constants.success] as? Bool else {
            return nil
        }
        
        var intent: PaymentIntent?
        
        if let paymentIntentDict = dict[Constants.paymentIntent] as? [String: Any] {
           intent = mapPaymentIntent(dict: paymentIntentDict)
        }
        
        do {
            if let action = dict[Constants.action] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: action, options: .prettyPrinted)
                let action = try JSONDecoder().decode(Action.self, from: jsonData)
                
                return AdyenPaymentAnswerResponse(success: success, action: action, paymentIntent: intent)
            }
        } catch { }

        return AdyenPaymentAnswerResponse(success: success, action: nil, paymentIntent: intent)
    }
    
    func adyenMapPaymentMethods(creatorID: Int, amount: Int, currency: Currency) -> [String: Any] {
        
        return [Constants.id: creatorID,
                Constants.amount: "\(amount)",
                Constants.currencyCode: currency.rawValue]
    }
    
    func mapResponseFromHasPaymentMethod(dict: [String: Any]) -> Bool? {
        guard let has = dict[Constants.hasPaymentMethod] as? Bool else {
            
            return nil
        }
        
        return has
    }
    
    func mapRedirectURL(dict: [String: Any]) -> URL? {
        guard let redirectURL = dict[Constants.redirectURL] as? String,
              let url = URL(string: redirectURL) else {
                  
                  return nil
              }
        
        return url
    }
    
    func IDParam(id: Int) -> [String: Any] {
        return [Constants.id: "\(id)"]
    }
    
    func amountIDAndCurrency(id: Int, amount: Int, currency: Currency) -> [String: Any] {
        return [Constants.id: "\(id)",
                Constants.amount: "\(amount)",
                Constants.currencyCode: currency.rawValue]
    }
    
    func startAdyenAccountCreation(firstName: String, lastName: String, email: String, countryCode: String) -> [String: Any] {
        return [Constants.firstName: firstName,
                Constants.lastName: lastName,
                Constants.email: email,
                Constants.countryCode: countryCode]
    }
    
    func startAdyenBusinessAccountCreation(email: String, businessName: String, businessCountryCode: String) -> [String: Any] {
        return [Constants.email: email,
                Constants.businessName: businessName,
                Constants.businessCountryCode: businessCountryCode]
    }
    
    func mapResponseFromHasBankAccount(dict: [String: Any]) -> BankAccountSetup? {
        guard let has = dict[Constants.accountIsSet] as? Bool,
              let pending = dict[Constants.pendingVerification] as? Bool else {
            
            return nil
        }
        
        return (has, pending)
    }
    
    func mapPaymentIntent(dict: [String: Any]) -> PaymentIntent? {
        guard let reference = dict[Constants.paymentReference] as? String,
              let id = dict[Constants.id] as? Int else {
            
            return nil
        }
        
        return PaymentIntent(id: id, paymentReference: reference)
    }
    
    func mapEarnedAmount(dict: [String: Any]) -> EarnedAmount? {
        guard let amount = dict[Constants.amount] as? Int,
              let currency = dict[Constants.currency] as? String,
              let currencyE = Currency(rawValue: currency) else {
            
            return nil
        }
        
        return (amountCents: amount, currency: currencyE)
    }
    
    func mapURL(dict: [String: Any]) -> URL? {
        guard let link = dict[Constants.redirectURL] as? String,
              let url = URL(string: link) else {
            
            return nil
        }
        
        return url
    }
    
    func getEmepheralKey(apiVersion: String) -> [String: Any] {
        return [Constants.apiVersion: apiVersion]
    }
    
    func updatePaymentMethod(id: String) -> [String: Any] {
        return [Constants.paymentMethodID: id]
    }
    
    func mapPayments(dict: [String: Any]) -> [Payment]? {
        guard let paymentsArray = dict[Constants.payments] as? [[String: Any]] else {
            return nil
        }
        
        var payments = [Payment]()
        for dict in paymentsArray {
            if let payment = mapPayment(dict: dict) {
                payments.append(payment)
            }
        }
        
        return payments
    }
    
    // MARK: Private methods
    
    private func mapPayment(dict: [String: Any]) -> Payment? {
        guard let id = dict[Constants.id] as? Int,
              let paymentTypeRaw = dict[Constants.paymentType] as? String,
              let paymentType = PaymentType(rawValue: paymentTypeRaw),
              let earnedCents = dict[Constants.earnedCents] as? Int,
              let donatedCents = dict[Constants.donatedCents] as? Int,
              let currencyRaw = dict[Constants.currency] as? String,
              let currency = Currency(rawValue: currencyRaw),
              let createdAtStr = dict[Constants.createdAt] as? String,
              let date = Date.dateFromBackend(string: createdAtStr) else {
                  
                  return nil
              }
        
        var user: User?
        if let userDict = dict[Constants.from] as? [String: Any] {
            user = userMapper.mapUser(dict: userDict)
        }
        
        return Payment(id: id, earnedCents: earnedCents, donatedCents: donatedCents, currency: currency, type: paymentType, from: user, createdAt: date)
    }
    
}

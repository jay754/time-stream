//
//  BackendPaymentService.swift
//  TimeStream
//
//  Created by appssemble on 04.09.2021.
//

import Foundation




class BackendPaymentService {
    
    private struct Constants {
        static let payments = "payments/"
        
        static let earnedAmount = payments + "total_earned"
        static let currentMonthEarnings = payments + "current_month_earnings"
    }
    
    private let service = ServiceHelper()
    private let mapper = PaymentServiceMapper()
    
    // MARK: Methods

    
    func getTotalEarned(completion: @escaping EarnedClosure) {
        service.GET(path: Constants.earnedAmount, data: nil) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let earned = self.mapper.mapEarnedAmount(dict: dict) else {
                    completion(.error(nil))
                    return
                }
                
                completion(.success(earned))
            }
        }
    }
    
    func getCurrentMonthEarnings(completion: @escaping PaymentsClosure) {
        service.GET(path: Constants.currentMonthEarnings, data: nil) { response in
            switch response {
            case .error(let error):
                completion(.error(error))
                
            case .success(let dict):
                guard let payments = self.mapper.mapPayments(dict: dict) else {
                    completion(.error(nil))
                    return
                }
                
                completion(.success(payments))
            }
        }
    }
}

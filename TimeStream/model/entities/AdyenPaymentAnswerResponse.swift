//
//  AdyenPaymentAnswerResponse.swift
//  TimeStream
//
//  Created by appssemble on 29.03.2022.
//

import Foundation
import Adyen

struct AdyenPaymentAnswerResponse {
    let success: Bool
    let action: Action?
    let paymentIntent: PaymentIntent?
}

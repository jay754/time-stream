//
//  AdyenPaymentActionResponse.swift
//  TimeStream
//
//  Created by appssemble on 30.03.2022.
//

import Foundation
import Adyen

enum AdyenPaymentActionResponse {
    case action(Action)
    case intent(PaymentIntent)
}

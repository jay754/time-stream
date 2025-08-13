//
//  AdyenPaymentMethodsResponse.swift
//  TimeStream
//
//  Created by appssemble on 29.03.2022.
//

import Foundation
import Adyen

struct AdyenPaymentMethodsResponse {
    let methods: PaymentMethods
    let amountCents: Int
    let currency: Currency
}

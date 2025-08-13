//
//  Payments.swift
//  TimeStream
//
//  Created by appssemble on 11.11.2021.
//

import Foundation

enum PaymentType: String {
    case tip
    case request
}

struct Payment {
    let id: Int
    let earnedCents: Int
    let donatedCents: Int
    let currency: Currency
    let type: PaymentType
    let from: User?
    let createdAt: Date
}

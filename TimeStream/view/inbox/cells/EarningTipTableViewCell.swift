//
//  EarningVideoTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 01.11.2021.
//

import UIKit

class EarningTipTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: Methods
    
    func populate(payment: Payment) {
        dateLabel.text = payment.createdAt.dayMonthFormat()
        userImageView.setUserImage(url: payment.from?.photoURL)
        nameLabel.text = payment.from?.name ?? "uknown.user".localized
        valueLabel.text = "+" + payment.earnedCents.formattedPriceDecimals(currency: payment.currency)
    }
}

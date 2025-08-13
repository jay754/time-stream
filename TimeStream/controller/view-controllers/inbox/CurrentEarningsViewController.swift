//
//  CurrentEarningsViewController.swift
//  TimeStream
//
//  Created by appssemble on 01.11.2021.
//

import UIKit

protocol CurrentEarningsViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
    func currentEarningsGoToUser(vc: CurrentEarningsViewController, user: User)
}

class CurrentEarningsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var flowDelegate: CurrentEarningsViewControllerFlowDelegate?
    
    
    private struct Constants {
        static let paymentCell = "EarningVideoTableViewCell"
        static let tipCell = "EarningTipTableViewCell"
    }
    
    @IBOutlet weak var paymentsButton: UIButton!
    @IBOutlet weak var paymentsIndicator: UIView!
    
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var tipsButton: UIButton!
    @IBOutlet weak var tipsIndicator: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedSection: PaymentType = .request {
        didSet {
            setType()
        }
    }
    
    private var requests = [Payment]()
    private var tips = [Payment]()
    
    private let paymentsService = BackendPaymentService()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(delegate: flowDelegate)
        selectedSection = .request
        
        tableView.register(UINib(nibName: "EarningVideoTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.paymentCell)
        tableView.register(UINib(nibName: "EarningTipTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.tipCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        totalIncomeLabel.text = "0"
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func payments(_ sender: Any) {
        selectedSection = .request
        
        reloadData()
    }
    
    @IBAction func tips(_ sender: Any) {
        selectedSection = .tip
        
        reloadData()
    }
    
    // MARK: Table view datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSection == .request {
            return requests.count
        }
        
        return tips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSection == .request {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.paymentCell, for: indexPath) as! EarningVideoTableViewCell
            let payment = requests[indexPath.row]
            cell.populate(payment: payment)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tipCell, for: indexPath) as! EarningTipTableViewCell
        let payment = tips[indexPath.row]
        cell.populate(payment: payment)
        
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedSection == .request {
            let payment = requests[indexPath.row]
            
            if let from = payment.from {
                flowDelegate?.currentEarningsGoToUser(vc: self, user: from)
            }
            return
        }
        
        let payment = tips[indexPath.row]
        if let from = payment.from {
            flowDelegate?.currentEarningsGoToUser(vc: self, user: from)
        }
    }
    
    // MARK: Private methods
    
    private func loadData() {
        loading = true
        paymentsService.getCurrentMonthEarnings { result in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let payments):
                self.handlePayments(payments: payments)
            }
        }
    }
    
    private func handlePayments(payments: [Payment]) {
        requests = payments.filter({$0.type == .request}).sorted(by: {$0.createdAt > $1.createdAt})
        tips = payments.filter({$0.type == .tip}).sorted(by: {$0.createdAt > $1.createdAt})
        
        if let payment = payments.first {
            let total = payments.map({$0.earnedCents}).reduce(0, +)
            totalIncomeLabel.text = total.formattedPriceDecimals(currency: payment.currency)
        } else {
            totalIncomeLabel.text = "0"
        }
        
        reloadData()
    }
    
    private func reloadData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    private func setType() {
        paymentsButton.setTitleColor(UIColor.text, for: .normal)
        tipsButton.setTitleColor(UIColor.text, for: .normal)

        paymentsIndicator.isHidden = true
        tipsIndicator.isHidden = true
        
        switch selectedSection {
        case .request:
            paymentsButton.setTitleColor(UIColor.accent, for: .normal)
            paymentsIndicator.isHidden = false
            
        case .tip:
            tipsButton.setTitleColor(UIColor.accent, for: .normal)
            tipsIndicator.isHidden = false
        }
    }
}

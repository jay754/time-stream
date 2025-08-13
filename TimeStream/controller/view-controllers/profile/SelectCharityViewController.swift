//
//  SelectCharityViewController.swift
//  TimeStream
//
//  Created by appssemble on 10.08.2021.
//

import UIKit

protocol SelectCharityFlowDelegate: BaseViewControllerFlowDelegate {
    
}

class SelectCharityViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var flowDelegate: SelectCharityFlowDelegate?
    var charitySelectionClosure: CharitySelectionClosure?
    var initialySelectedCharity: Charity?
    
    
    struct Constants {
        static let cellIdentifier = "CharityTableViewCell"
    }

    @IBOutlet weak var tableView: UITableView!
    
    private var charities = [Charity]()
    private let charityService = CharityService()
    
    private var selectedCharity: Charity? {
        didSet {
            if let charity = selectedCharity {
                charitySelectionClosure?(charity)
            }
        }
    }
    
    private var previouslySelectedCell: CharityTableViewCell?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBackButton(delegate: flowDelegate)
        
        tableView.register(UINib(nibName: "CharityTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 91
        tableView.rowHeight = UITableView.automaticDimension
        
        selectedCharity = initialySelectedCharity
        loadCharities()
    }
    
    // MARK: Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! CharityTableViewCell
        cell.populate(charity: charities[indexPath.row])
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CharityTableViewCell {
            let charity = charities[indexPath.row]
            cell.set(selected: charity.title == selectedCharity?.title)
        }
    }
    
    // MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCharity = charities[indexPath.row]
        tableView.reloadData()
    }
    
    // MARK: Private methods
    
    private func loadCharities() {
        loading = true
        charityService.getCharities { (result) in
            self.loading = false
            
            switch result {
            case .error:
                self.showGenericError()
                
            case .success(let charities):
                self.charities = charities
                self.tableView.reloadData()
            }
        }
    }

}

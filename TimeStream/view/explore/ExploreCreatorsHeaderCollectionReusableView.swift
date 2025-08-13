//
//  ExploreCreatorsHeaderCollectionReusableView.swift
//  TimeStream
//
//  Created by appssemble on 08.12.2021.
//

import UIKit

protocol ExploreCreatorsHeaderCollectionReusableViewDelegate: AnyObject {
    func exploreCreatorsHeaderGoToUser(header: ExploreCreatorsHeaderCollectionReusableView, user: User)
    func exploreCreatorsHeaderFollowUser(header: ExploreCreatorsHeaderCollectionReusableView, user: User)
}

class ExploreCreatorsHeaderCollectionReusableView: UICollectionReusableView, ExploreCreatorCollectionViewCellDelegate {

    weak var delegate: ExploreCreatorsHeaderCollectionReusableViewDelegate?
    
    private struct Constants {
        static let cellIdentifier = "ExploreCreatorCollectionViewCell"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    private var users = [User]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "ExploreCreatorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func populate(users: [User]) {
        self.users = users
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Cell delegate
    
    func exploreCreatorFollowCreator(cell: ExploreCreatorCollectionViewCell, user: User) {
        delegate?.exploreCreatorsHeaderFollowUser(header: self, user: user)
    }

}

extension ExploreCreatorsHeaderCollectionReusableView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! ExploreCreatorCollectionViewCell
        
        let user = users[indexPath.row]
        cell.populate(user: user)
        cell.delegate = self
        
        return cell
    }
    
}

extension ExploreCreatorsHeaderCollectionReusableView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.exploreCreatorsHeaderGoToUser(header: self, user: user)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 84, height: 98)
    }
    
}

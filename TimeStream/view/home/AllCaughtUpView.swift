//
//  AllCaughtUpView.swift
//  TimeStream
//
//  
//

import UIKit

protocol AllCaughtUpViewDelegate: AnyObject {
    func allCaughtUpSelected(category: Category)
    func allCaughtUpSelected(video: Video)
}

class AllCaughtUpView: UIView, HashtagsContainerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: AllCaughtUpViewDelegate?
    
    private struct Constants {
        static let cellIdentifier = "AllCaughtUpCellCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 6
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    @IBOutlet weak var tagsContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let tags = HashtagsContainer.loadFromNib()
    
    var data: HomeExplore? {
        didSet {
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
            }
            if let data = data {
                tags.populate(items: data.categories)
            }
        }
    }
    
    // MARK: Methods
    
    override func awakeFromNib() {
        tagsContainerView.addSubview(tags)
        tags.pinToSuperviewTop()
        tags.delegate = self
        
        
        collectionView.register(UINib(nibName: "AllCaughtUpCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: Hashtag delegate
    
    func hashtagContainerDidSelect(container: HashtagsContainer, category: Category) {
        delegate?.allCaughtUpSelected(category: category)
    }
    
    // MARK: Collection view datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = data else {
            return 0
        }
        
        let count = data.videos.count
        if count == 0 {
            return 0
        }
        
        if section == 0 {
            return 1
        }
        
        if count > 1 {
            return data.videos.count - 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! AllCaughtUpCellCollectionViewCell
        
        guard let data = data else {
            return cell
        }
        
        let isMain = indexPath.section == 0
        var video: Video!
        if isMain {
            video = data.videos[0]
        } else {
            video = data.videos[indexPath.row + 1]
        }
        
        cell.populate(name: video.postedBy.name, expertise: video.category.name, isMain: isMain)
        cell.personalityImageView.setImage(url: video.thumbnailURL)
        
        return cell
    }
    
    // MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: 185, height: collectionView.bounds.height)
        }
        
        return CGSize(width: 91, height: (collectionView.bounds.height) / 2 - 0.5 * Constants.collectionViewInterRowsSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
       return Constants.collectionViewInterRowsSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
        return Constants.collectionViewInterColumnsSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            
        } else {
            // Normal insets for collection
            return UIEdgeInsets(top: 0, left: Constants.collectionViewInterColumnsSpacing, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = data else {
            return
        }
        
        let isMain = indexPath.section == 0
        var video: Video!
        if isMain {
            video = data.videos[0]
        } else {
            video = data.videos[indexPath.row + 1]
        }
        
        delegate?.allCaughtUpSelected(video: video)
    }
}

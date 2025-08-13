//
//  ExploreVideosTableViewCell.swift
//  TimeStream
//
//  Created by appssemble on 07.12.2021.
//

import UIKit

protocol ExploreVideosTableViewCellDelegate: AnyObject {
    func exploreVideosCellGoToVideo(cell: ExploreVideosTableViewCell, video: Video)
}

class ExploreVideosTableViewCell: UITableViewCell {
    
    weak var delegate: ExploreVideosTableViewCellDelegate?
    
    struct Constants {
        static let cellIdentifier = "VideoCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 16
        static let collectionViewInterColumnsSpacing: CGFloat = 16
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var videos = [Video]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func populate(videos: [Video]) {
        self.videos = videos
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }

}


extension ExploreVideosTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        let video = videos[indexPath.row]
        cell.populate(video: video)
        
        return cell
    }
}

extension ExploreVideosTableViewCell: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        delegate?.exploreVideosCellGoToVideo(cell: self, video: video)
    }
}


extension ExploreVideosTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = 271.0
        let width = height / 1.46
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
       return Constants.collectionViewInterRowsSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return Constants.collectionViewInterColumnsSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            // Normal insets for collection
        return UIEdgeInsets(top: 0, left: Constants.collectionViewInterColumnsSpacing, bottom: 0, right: Constants.collectionViewInterColumnsSpacing)
    }
}

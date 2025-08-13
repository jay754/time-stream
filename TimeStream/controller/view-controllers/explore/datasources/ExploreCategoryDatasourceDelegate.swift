//
//  ExploreCategoryDatasourceDelegate.swift
//  TimeStream
//
//  Created on 08.12.2021.
//

import UIKit


class ExploreCategoryDatasourceDelegate: NSObject, ExploreCreatorsHeaderCollectionReusableViewDelegate {
    
    weak var actionsDelegate: ExploreActionsDelegate?
    
    private struct Constants {
        static let videoCell = "VideoCollectionViewCell"
        
        static let creatorsHeader = "ExploreCreatorsHeaderCollectionReusableView"
        static let videosHeader = "videosHeader"
        
        static let collectionViewInterRowsSpacing: CGFloat = 12
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    private let collectionView: UICollectionView
    private var hasCreators = true
    
    private var popularContentCreators = [User]()
    private var popularVideos = [Video]()
    private var currentPage = 1
    private var category = Category.entertainment
    
    private let service = ExploreService()
    
    // MARK: Lifecycle
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        super.init()
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.videoCell)
        
        collectionView.register(UINib(nibName: "ExploreHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.videosHeader)
        collectionView.register(UINib(nibName: "ExploreCreatorsHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.creatorsHeader)
    }
    
    // MARK: Public
    
    func populate(category: Category) {
        self.category = category
        self.currentPage = 1
        self.popularVideos.removeAll()
        self.popularContentCreators.removeAll()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.reloadData()
        
        loadData()
    }
    
    func reloadDataWithoutLoad() {
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.numberOfSections > 0) && (collectionView.numberOfItems(inSection: 0) > 0) {
            collectionView.superview?.endEditing(true)
        }
    }
    
    // MARK: Header delegate
    
    func exploreCreatorsHeaderFollowUser(header: ExploreCreatorsHeaderCollectionReusableView, user: User) {
        actionsDelegate?.exploreActionFollowUser(user: user)
    }
    
    func exploreCreatorsHeaderGoToUser(header: ExploreCreatorsHeaderCollectionReusableView, user: User) {
        actionsDelegate?.exploreActionGoToUser(user: user)
    }
    
    // MARK: Private methods
    
    private func loadData() {
        collectionView.startAutoRefresh {
            self.loadVideos()
        }
        
        loadVideos()
        loadCreators()
    }
    
    private func loadVideos() {
        collectionView.beginRefresh()
        service.popularVideos(category: category, page: currentPage) { result in
            self.collectionView.endCurrentRefresh()
            
            switch result {
            case .error:
                return
                
            case .success(let videos):
                self.popularVideos.removeExtraItems(pageSize: AppConstants.numberOfItemsPerPage)
                self.popularVideos += videos
                
                if videos.count == AppConstants.numberOfItemsPerPage {
                    // Increase the page number
                    self.currentPage += 1
                }
                
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadCreators() {
        collectionView.beginRefresh()
        service.popularCreators(category: category) { result in
            self.collectionView.endCurrentRefresh()
            
            switch result {
            case .error:
                // Do nothing
                break
                
            case .success(let users):
                self.popularContentCreators = users
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension ExploreCategoryDatasourceDelegate: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if popularContentCreators.count == 0 {
            return 1
        }
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.clearBackground()
        
        if section == 0 && popularContentCreators.count > 0 {
            return 0
        }
        
        if popularContentCreators.count == 0 && popularVideos.count == 0 {
            collectionView.setMessage("no.items.for.your.search.criteria".localized)
        } else {
            collectionView.clearBackground()
        }
        
        return popularVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.videoCell, for: indexPath) as! VideoCollectionViewCell
        let video = popularVideos[indexPath.row]
        cell.populate(video: video)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 0 && popularContentCreators.count > 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.creatorsHeader, for: indexPath) as? ExploreCreatorsHeaderCollectionReusableView
        
                header?.populate(users: popularContentCreators)
                header?.delegate = self

                return header!
            }
            
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.videosHeader, for: indexPath) as? ExploreHeaderCollectionReusableView

            return header!
        default:
            assert(false, "Unexpected element kind")
        }

        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if section == 0 && popularContentCreators.count > 0 {
            return CGSize(width: collectionView.frame.width, height: 160)
        }

        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
}

extension ExploreCategoryDatasourceDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        let video = popularVideos[indexPath.row]
        actionsDelegate?.exploreActionGoToVideoDetails(video: video)
    }
}


extension ExploreCategoryDatasourceDelegate: UICollectionViewDelegateFlowLayout {
    
    // MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let collectionWidth = Int(((collectionView.bounds.width - (2 * Constants.collectionViewInterRowsSpacing)) / 2))
        let width = CGFloat(collectionWidth) - (0.5 * Constants.collectionViewInterRowsSpacing)
        let height = width * 1.46
        
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

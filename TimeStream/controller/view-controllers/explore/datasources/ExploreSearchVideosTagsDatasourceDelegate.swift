//
//  ExploreSearchVideosDatasourceDelegate.swift
//  TimeStream
//
//  Created by appssemble on 09.12.2021.
//

import Foundation
import UIKit

class ExploreSearchVideosTagsDatasourceDelegate: NSObject {
    
    weak var actionsDelegate: ExploreActionsDelegate?
    
    private struct Constants {
        static let videoCell = "VideoCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 12
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    private let collectionView: UICollectionView
    private var hasCreators = true
    
    private var videos = [Video]()
    private var currentPage = 1
    private var term: String?
    private let service = ExploreService()
    
    private var newContent = false
    
    // MARK: Lifecycle
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        super.init()
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.videoCell)
    }
    
    // MARK: Public
    
    func populate() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        collectionView.reloadData()
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        collectionView.startAutoRefresh {
            if self.newContent {
                self.loadNewestItems()
                
                return
            }
            
            guard let term = self.term else {
                self.collectionView.endCurrentRefresh()
                return
            }
            
            self.loadItems(term: term)
        }
    }
    
    func search(term: String) {
        newContent = false
        guard term != self.term else {
            return
        }
        
        currentPage = 1
        videos.removeAll()
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        
        self.term = term
        
        loadItems(term: term)
    }
    
    func searchNewstVideos() {
        newContent = true
        currentPage = 1
        videos.removeAll()
        
        loadNewestItems()
    }
    
    func reloadDataWithoutLoad() {
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    func clearItems() {
        videos.removeAll()
        collectionView.reloadData()
        
        term = nil
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (collectionView.numberOfSections > 0) && (collectionView.numberOfItems(inSection: 0) > 0) {
            collectionView.superview?.endEditing(true)
        }
    }
    
    // MARK: Private methods
    
    private func loadItems(term: String) {
        guard term.count > 0 else {
            collectionView.endCurrentRefresh()
            return
        }
        
        collectionView.beginRefresh()
        service.searchTags(term: term, page: currentPage) { result in
            self.collectionView.endCurrentRefresh()

            switch result {
            case .error:
                break

            case .success(let videos):
                self.videos.removeExtraItems(pageSize: AppConstants.numberOfItemsPerPage)
                self.videos += videos

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
    
    private func loadNewestItems() {
        collectionView.beginRefresh()
        service.newestVideosFromTags(page: currentPage) { result in
            self.collectionView.endCurrentRefresh()
            
            switch result {
            case .error:
                break
                
            case .success(let videos):
                self.videos.removeExtraItems(pageSize: AppConstants.numberOfItemsPerPage)
                self.videos += videos
                
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
}

extension ExploreSearchVideosTagsDatasourceDelegate: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = videos.count
        
        if items == 0 {
            collectionView.setMessage("no.items.for.your.search.criteria".localized)
        } else {
            collectionView.clearBackground()
        }
        
       return items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.videoCell, for: indexPath) as! VideoCollectionViewCell
        let video = videos[indexPath.row]
        cell.populate(video: video)
        
        return cell
    }
}

extension ExploreSearchVideosTagsDatasourceDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        actionsDelegate?.exploreActionGoToVideoDetails(video: video)
    }
}

extension ExploreSearchVideosTagsDatasourceDelegate: UICollectionViewDelegateFlowLayout {
    
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

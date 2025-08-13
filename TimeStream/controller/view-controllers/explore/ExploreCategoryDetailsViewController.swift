//
//  ExploreCategoryDetailsViewController.swift
//  TimeStream
//
//  Created on 09.12.2021.
//

import UIKit

protocol ExploreCategoryDetailsFlowDelegate: BaseViewControllerFlowDelegate {
    func exploreCategoryGoToVideo(vc: ExploreCategoryDetailsViewController, video: Video)
}

class ExploreCategoryDetailsViewController: BaseViewController {
    
    weak var flowDelegate: ExploreCategoryDetailsFlowDelegate?
    
    var category: Category!
    
    private struct Constants {
        static let videoCell = "VideoCollectionViewCell"
        
        static let collectionViewInterRowsSpacing: CGFloat = 12
        static let collectionViewInterColumnsSpacing: CGFloat = 12
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var videos = [Video]()
    private var currentPage = 1
    
    private let service = ExploreService()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBackButton(delegate: flowDelegate)
        title = category.name
        
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.videoCell)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        collectionView.reloadData()
        
        collectionView.startAutoRefresh {
            self.loadVideos()
        }
        
        loadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Private methods
    
    private func loadVideos() {
        service.popularVideos(category: category, page: currentPage) { result in
            self.collectionView.endCurrentRefresh()
            
            switch result {
            case .error:
                return
                
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

extension ExploreCategoryDetailsViewController: UICollectionViewDataSource {
    
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

extension ExploreCategoryDetailsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        flowDelegate?.exploreCategoryGoToVideo(vc: self, video: video)
    }
}


extension ExploreCategoryDetailsViewController: UICollectionViewDelegateFlowLayout {
    
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

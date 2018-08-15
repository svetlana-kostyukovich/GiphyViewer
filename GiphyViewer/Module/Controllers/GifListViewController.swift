//
//  GifListViewController.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import UIKit
import FLAnimatedImage

enum State {
    case Trending
    case Search(String)
}

class GifListViewController: UIViewController {
    
    @IBOutlet weak var gifListCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    
    static var state: State = .Trending
    
    lazy var viewModel: GifListViewModel = {
        return GifListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
        
    }
    
    func initView() {
        self.navigationItem.title = "GIPHY"
        view.backgroundColor = UIColor.black
        
        gifListCollectionView.delegate = self
        gifListCollectionView.dataSource = self
        gifListCollectionView.backgroundColor = UIColor.black
        
        searchBar.delegate = self
        
        switch GifListViewController.state {
        case .Trending:
            searchBar.text = ""
        case .Search(let searchRequest):
            searchBar.text = searchRequest
        }

        refreshControl.addTarget(self, action: #selector(refreshCollectionView(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        if #available(iOS 10.0, *) {
            gifListCollectionView.refreshControl = refreshControl
        } else {
            gifListCollectionView.addSubview(refreshControl)
        }

    }
    
    func initVM() {
        
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.gifListCollectionView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.gifListCollectionView.alpha = 1.0
                        self?.activityIndicator.alpha = 0
                    })
                }
            }
        }
        switch GifListViewController.state {
        case .Trending:
            viewModel.initFetch()
        case .Search(let searchRequest):
            viewModel.initSearchFetch(searchRequest: searchRequest)
        }
        
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.gifListCollectionView.reloadData()
            }
        }
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func refreshCollectionView(sender: UIRefreshControl) {
        initVM()
        sender.endRefreshing()
    }
    
}

extension GifListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifListViewCellIdentifier", for: indexPath) as? GifListViewCell
            else {
                fatalError("No cell")
        }
        
        let cellVM = viewModel.getCellViewModel( at: indexPath )
        let gifData = try? Data(contentsOf: URL(string: cellVM.url)!)
        let imageData = FLAnimatedImage(gifData: gifData)
        cell.contentView.autoresizingMask = [.flexibleHeight]
        cell.animatedImage.animatedImage = imageData
        
        return cell
    }
}

extension GifListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        
        searchBar.resignFirstResponder()
        if !searchText.isEmpty {
            GifListViewController.state = .Search(searchText)
            
            let viewController:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "GifListViewControllerID"))!
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        GifListViewController.state = .Trending
    }
    
}

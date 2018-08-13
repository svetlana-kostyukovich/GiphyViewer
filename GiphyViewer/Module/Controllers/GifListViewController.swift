//
//  GifListViewController.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GifListViewController: UIViewController {

    @IBOutlet weak var gifListCollectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var viewModel: GifListViewModel = {
        return GifListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // init view model
        initVM()
        
    }
    
    func initView() {
        self.navigationItem.title = "GIPHY"
        view.backgroundColor = UIColor.black
        
        gifListCollectionView.delegate = self
        gifListCollectionView.dataSource = self
        gifListCollectionView.backgroundColor = UIColor.black
        
        searchBar.delegate = self
        
        //if let flowLayout = gifListCollectionView.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.estimatedItemSize = CGSize(width: 1, height: 1) }
        //tableView.estimatedRowHeight = 150
        //tableView.rowHeight = UITableViewAutomaticDimension
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
        
        viewModel.initFetch()
        
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.gifListCollectionView.reloadData()
            }
        }
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        cell.animatedImage.animatedImage = imageData
        //cell.imageView?.sd_setImage(with: URL( string: cellVM.url ), completed: nil)

        return cell
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let side = gifListCollectionView.bounds.width
        //collectionViewLayout. estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        return CGSize(width: side, height: side)
    }*/
    
    // MARK: - UICollectionViewDelegateFlowLayout
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-10.0, height: collectionView.frame.height/4-10.0)
    }*/
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 0.0, right: 5.0)
}*/
}

extension GifListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        /*let searchText = searchBar.text ?? ""

        
        if !searchText.isEmpty {
            viewModel.cleanGifsList()
            viewModel.initSearchFetch(searchRequest: searchText)
            print("Hi there")
            viewModel.reloadCollectionViewClosure = { [weak self] () in
                DispatchQueue.main.async {
                    self?.gifListCollectionView.reloadData()
                }
            }
        }*/
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
    
        searchBar.resignFirstResponder()
        if !searchText.isEmpty {
            viewModel.cleanGifsList()
            viewModel.initSearchFetch(searchRequest: searchText)
            print("Hi there")
            viewModel.reloadCollectionViewClosure = { [weak self] () in
                DispatchQueue.main.async {
                    self?.gifListCollectionView.reloadData()
                }
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //gifs.removeAll()
        searchBar.text?.removeAll()
        searchBar.resignFirstResponder()
        //uploadGifs()
        /*viewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.gifListCollectionView.reloadData()
            }
        }*/
        searchBar.showsCancelButton = false
    }
    
}

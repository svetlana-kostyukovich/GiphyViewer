//
//  GifListViewModel.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import Foundation

class GifListViewModel {
    
    //MARK: Properties
    let apiService: APIServiceProtocol
    private var gifs: [Gif] = [Gif]()
    private var cellViewModels: [GifListCellViewModel] = [GifListCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        //print ("count:  \(cellViewModels.count)")
        return cellViewModels.count
    }
    
    var isAllowSegue: Bool = false
    
    var selectedGif: Gif?
    
    var reloadCollectionViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    //MARK: Methods
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        apiService.fetchTrendingGif { [weak self] (success, gifs, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.error
            } else {
                self?.processFetchedGif(gifs: gifs)
            }
        }
    }
    
    func initSearchFetch(searchRequest: String) {
        self.isLoading = true
        cleanGifsList()
        apiService.fetchSearchGif(searchRequest: searchRequest) { [weak self] (success, gifs, error) in
            self?.isLoading = false
            if gifs.isEmpty {
                self?.alertMessage = "No GIFs found :("
            }
            if let error = error {
                self?.alertMessage = error.error
            } else {
                self?.processFetchedGif(gifs: gifs)
            }
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> GifListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel( gif: Gif ) -> GifListCellViewModel {
        
        if let url = gif.images.original.url {
            return GifListCellViewModel(url: url)
        }
        return GifListCellViewModel(url: "")
    }
    
    func cleanGifsList() {
        gifs.removeAll()
    }
    
    private func processFetchedGif( gifs: [Gif] ) {
        self.gifs = gifs // Cache
        var vms = [GifListCellViewModel]()
        for gif in gifs {
            vms.append( createCellViewModel(gif: gif) )
        }
        self.cellViewModels = vms
    }
    
}

struct GifListCellViewModel {
    let url: String
}

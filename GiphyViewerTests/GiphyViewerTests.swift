//
//  GiphyViewerTests.swift
//  GiphyViewerTests
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class GiphyViewerTests: XCTestCase {
    
    var sut: GifListViewModel!
    var mockAPIService: MockApiService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockApiService()
        sut = GifListViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func test_fetch_gif() {
        // Given
        mockAPIService.completeGifs = [Gif]()
        
        // When
        sut.initFetch()
        
        // Assert
        XCTAssert(mockAPIService!.isFetchTrendingGifCalled)
    }
    
    func test_fetch_gif_fail() {
        
        // Given a failed fetch with a certain failure
        let error = APIError.permissionDenied
        
        // When
        sut.initFetch()
        
        mockAPIService.fetchFail(error: error )
        
        // Sut should display predefined error message
        XCTAssertEqual( sut.alertMessage, error.rawValue )
        
    }
    
    func test_fetch_search_gif() {
        // Given
        mockAPIService.completeGifs = [Gif]()
        
        // When
        sut.initSearchFetch(searchRequest: "String")
        
        // Assert
        XCTAssert(mockAPIService!.isFetchTrendingGifCalled)
    }
    
    func test_fetch_search_gif_fail() {
        
        // Given a failed fetch with a certain failure
        let error = APIError.permissionDenied
        
        // When
        sut.initSearchFetch(searchRequest: "String")
        
        mockAPIService.fetchFail(error: error )
        
        // Sut should display predefined error message
        XCTAssertEqual( sut.alertMessage, error.rawValue )
        
    }
    
    func test_create_cell_view_model() {
        // Given
        let gifs = StubGenerator().stubGifs()
        mockAPIService.completeGifs = gifs
        let expect = XCTestExpectation(description: "reload closure triggered")
        sut.reloadCollectionViewClosure = { () in
            expect.fulfill()
        }
        
        // When
        sut.initFetch()
        mockAPIService.fetchSuccess()
        
        // Number of cell view model is equal to the number of gifs
        XCTAssertEqual( sut.numberOfCells, gifs.count )
        
        // XCTAssert reload closure triggered
        wait(for: [expect], timeout: 1.0)
        
    }
    
    func test_loading_when_fetching() {
        
        //Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }
        
        //when fetching
        sut.initFetch()
        
        // Assert
        XCTAssertTrue( loadingStatus )
        
        // When finished fetching
        mockAPIService!.fetchSuccess()
        XCTAssertFalse( loadingStatus )
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_get_cell_view_model() {
        
        //Given a sut with fetched gifs
        goToFetchGifFinished()
        
        let indexPath = IndexPath(row: 1, section: 0)
        let testGif = mockAPIService.completeGifs[indexPath.row]
        
        // When
        let vm = sut.getCellViewModel(at: indexPath)
        
        //Assert
        XCTAssertEqual( vm.url, testGif.images.original.url)
        
    }
    
    func test_cell_view_model() {
        //Given gifs
        let images = Images(original: Images.Original(url: "url"))
        let gif = Gif(id: "id", title: "Title", images: images)
        
        // When create cell view model
        let cellViewModel = sut!.createCellViewModel( gif: gif )
        
        // Assert the correctness of display information
        XCTAssertEqual( gif.images.original.url, cellViewModel.url )
        
    }
    
}

//MARK: State control
extension GiphyViewerTests {
    private func goToFetchGifFinished() {
        mockAPIService.completeGifs = StubGenerator().stubGifs()
        sut.initFetch()
        mockAPIService.fetchSuccess()
    }
}

class MockApiService: APIServiceProtocol {
    
    var isFetchTrendingGifCalled = false
    var isFetchSearchGifCalled = false
    
    var completeGifs: [Gif] = [Gif]()
    var completeClosure: ((Bool, [Gif], APIError?) -> ())!
    
    func fetchTrendingGif(complete: @escaping (Bool, [Gif], APIError?) -> ()) {
        isFetchTrendingGifCalled = true
        completeClosure = complete
        
    }
    
    func fetchSearchGif(searchRequest: String, complete: @escaping (Bool, [Gif], APIError?) -> ()) {
        isFetchSearchGifCalled = true
        completeClosure = complete
        
    }
    
    func fetchSuccess() {
        completeClosure( true, completeGifs, nil )
    }
    
    func fetchFail(error: APIError?) {
        completeClosure( false, completeGifs, error )
    }
    
}

class StubGenerator {
    func stubGifs() -> [Gif] {
        let path = Bundle.main.path(forResource: "content", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let gifs = try! decoder.decode(Gifs.self, from: data)
        return gifs.data
    }
    
}

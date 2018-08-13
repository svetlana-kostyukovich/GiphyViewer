//
//  APIServiceTests.swift
//  GiphyViewerTests
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class APIServiceTests: XCTestCase {
    
    var sut: APIService?
    
    override func setUp() {
        super.setUp()
        sut = APIService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_fetch_trending_gifs() {
        
        // Given A apiservice
        let sut = self.sut!
        
        // When fetch popular gif
        let expect = XCTestExpectation(description: "callback")
        
        sut.fetchTrendingGif(complete: { (success, gifs, error) in
            expect.fulfill()
            XCTAssertEqual( gifs.count, 20)
            for gif in gifs {
                XCTAssertNotNil(gif.id)
            }
            
        })
        
        wait(for: [expect], timeout: 3.1)
    }
    
    func test_fetch_search_gifs() {
        
        // Given A apiservice
        let sut = self.sut!
        
        // When fetch popular gif
        let expect = XCTestExpectation(description: "callback")
        
        sut.fetchSearchGif(complete: { (success, gifs, error) in
            expect.fulfill()
            XCTAssertEqual( gifs.count, 20)
            for gif in gifs {
                XCTAssertNotNil(gif.id)
            }
            
        })
        
        wait(for: [expect], timeout: 3.1)
    }
    
}

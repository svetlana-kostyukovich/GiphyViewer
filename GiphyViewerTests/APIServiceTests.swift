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
    
    func test_fetch_trending_photos() {
        
        // Given A apiservice
        let sut = self.sut!
        
        // When fetch popular photo
        let expect = XCTestExpectation(description: "callback")
        
        sut.fetchTrendingGif(complete: { (success, photos, error) in
            expect.fulfill()
            XCTAssertEqual( photos.count, 20)
            for photo in photos {
                XCTAssertNotNil(photo.id)
            }
            
        })
        
        wait(for: [expect], timeout: 3.1)
    }
    
}

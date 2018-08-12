//
//  APIService.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

protocol APIServiceProtocol {
    func fetchTrendingGif( complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() )
}

class APIService: APIServiceProtocol {
    
    private struct API {
            static let APPID = "dc6zaTOxFJmzC"
            static let BaseURL = "https://api.giphy.com/v1/"
        }
    
    enum ResourcePath: String {
        case Trending = "gifs/trending"
        case Search = "gifs/search"
        
        var path: String {
            return API.BaseURL + rawValue
        }
    }
    
    // Simulate a long waiting for fetching
    func fetchTrendingGif( complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "content", ofType: "json")!
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                    let gifs = try decoder.decode(Gifs.self, from: data)
                complete( true,  gifs.data, nil )
            } catch {
                print(error)
            }
          /*  let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601
            do {
                let gifs = try decoder.decode(Gifs.self, from: data)
            } catch {
                print(error)
            }
            complete( true,  gifs.gifs, nil ) */
        }
    }
    
    
    
}

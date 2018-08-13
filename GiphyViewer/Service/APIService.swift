//
//  APIService.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import Foundation
import Alamofire

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

protocol APIServiceProtocol {
    func fetchTrendingGif( complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() )
    func fetchSearchGif(searchRequest: String, complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() )
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
    
    enum RequestParameters{
        case Trending
        case Search(String)
        
        var parameters: [String: Any] {
            switch self {
            case .Trending:
                return ["api_key" : API.APPID, "limit" : 100]
            case .Search(let searchRequest):
                return ["api_key" : API.APPID, "limit" : 100, "q": searchRequest]
            }
        }
    }
    
    // Simulate a long waiting for fetching
    func fetchTrendingGif( complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            let parameters = RequestParameters.Trending.parameters
            let path = APIService.ResourcePath.Trending.path
            
            Alamofire.request(path, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success(_):
                    //print(json)
                    let json = response.data
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    do {
                        let gifs = try decoder.decode(Gifs.self, from: json!)
                    complete( true,  gifs.data, nil )
                    } catch {
                        print("Error", error.localizedDescription)
                    }
                case .failure(let error):
                    print("Status code", response.response?.statusCode ?? 0)
                    print("Error", error.localizedDescription)
                    complete(false, [Gif](), nil)
                }
            }
        }
    }
    
    func fetchSearchGif( searchRequest: String, complete: @escaping ( _ success: Bool, _ gifs: [Gif], _ error: APIError? )->() ) {
        DispatchQueue.global().async {
            let parameters = RequestParameters.Search(searchRequest).parameters
            let path = APIService.ResourcePath.Search.path

            Alamofire.request(path, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success(_):
                    //print(json)
                    let json = response.data
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    do {
                        let gifs = try decoder.decode(Gifs.self, from: json!)
                        complete( true,  gifs.data, nil )
                    } catch {
                        print("Error", error.localizedDescription)
                    }
                case .failure(let error):
                    print("Status code", response.response?.statusCode ?? 0)
                    print("Error", error.localizedDescription)
                    complete(false, [Gif](), nil)
                }
            }
        }
    }
    
}

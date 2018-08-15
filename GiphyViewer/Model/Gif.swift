//
//  Gif.swift
//  GiphyViewer
//
//  Created by Светлана Лобан on 8/12/18.
//  Copyright © 2018 Sviatlana Loban. All rights reserved.
//

import Foundation

struct Gifs: Codable {
    let data: [Gif]
}
struct Images: Codable {
    let original: Original
    
    struct Original: Codable {

    let url: String?
    }
}

struct Gif: Codable {
    let id: String!
    let title: String?
    let images: Images
}

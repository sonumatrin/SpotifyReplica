//
//  APICategoryResponse.swift
//  Spotify
//
//  Created by Sonu Martin on 13/06/21.
//

import Foundation

struct AllCategoryResponse: Codable {
    
    let categories: Categories
    
    struct Categories: Codable {
        let items: [Category]
    }
    
}

struct Category: Codable {
    
    let id: String
    let name: String
    let icons: [APIImage]
    
}

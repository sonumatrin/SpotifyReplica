//
//  Playlist.swift
//  Spotify
//
//  Created by Sonu Martin on 16/04/21.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]?
    let name: String
    let owner: User
}
 

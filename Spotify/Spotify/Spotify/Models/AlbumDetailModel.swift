//
//  AlbumDetailModel.swift
//  Spotify
//
//  Created by Sonu Martin on 11/05/21.
//

import Foundation

struct AlbumDetailModel: Codable {
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TrackResponse
}
struct TrackResponse: Codable {
    let items: [AudioTrack]
    
}



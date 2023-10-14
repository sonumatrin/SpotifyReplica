//
//  PlaylistDetailedModel.swift
//  Spotify
//
//  Created by Sonu Martin on 11/05/21.
//

import Foundation

struct PlaylistDetailedModel: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTracksResponse?
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}

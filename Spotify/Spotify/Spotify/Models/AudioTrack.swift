//
//  AudioTrack.swift
//  Spotify
//
//  Created by Sonu Martin on 16/04/21.
//

import Foundation

struct AudioTrack: Codable {
    var album: Album?
    let artists: [Artist]
    let available_markets: [String]
    let disc_number: Int?
    let duration_ms: Int?
    let external_urls: [String: String]
    let id: String
    let name: String
    let popularity: Int?
    let preview_url: String?
}

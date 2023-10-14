//
//  SearchResult.swift
//  Spotify
//
//  Created by Sonu Martin on 18/07/21.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
    
}

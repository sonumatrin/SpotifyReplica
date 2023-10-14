//
//  NewRleasesViewModel.swift
//  Spotify
//
//  Created by Sonu Martin on 08/05/21.
//

import Foundation

struct NewRleasesCellViewModel: Codable {
    let name: String
    let artworkURL: URL?
    let numberOfTracks: Int
    let artistName: String
}

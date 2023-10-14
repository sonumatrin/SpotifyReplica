//
//  File.swift
//  Spotify
//
//  Created by Sonu Martin on 27/04/21.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}
struct Option {
    let title: String
    let handler: () -> Void
}

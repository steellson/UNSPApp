//
//  Photo.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import Foundation

struct Photo {
    let id: String
    let links: GetPhotosResponseLinks
}

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - GetPhotosResponseLinks

struct GetPhotosResponseLinks: Decodable {
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

//
//  Photo.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import Foundation

struct Photo {
    let id: String
    let description: String?
    let slug: String
    let width: Int
    let height: Int
    let urls: Urls
    let links: GetPhotosResponseLinks
}

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(urls.thumb)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.urls.thumb == rhs.urls.thumb
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

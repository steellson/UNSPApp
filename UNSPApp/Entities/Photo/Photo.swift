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


// MARK: - GetPhotosResponseLinks

struct GetPhotosResponseLinks: Decodable {
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

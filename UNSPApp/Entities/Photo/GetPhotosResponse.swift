//
//  GetPhotosResponseElement.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import Foundation

typealias GetPhotosResponse = [GetPhotosResponseElement]

struct GetPhotosResponseElement: Decodable {
    let id, slug: String
    let createdAt: String?
    let updatedAt: String?
    let promotedAt: String?
    let width, height: Int
    let color, blurHash: String
    let description: String?
    let altDescription: String?
    let urls: Urls
    let links: GetPhotosResponseLinks
    let likes: Int
    let likedByUser: Bool

    enum CodingKeys: String, CodingKey {
        case id, slug
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width, height, color
        case blurHash = "blur_hash"
        case description
        case altDescription = "alt_description"
        case urls, links, likes
        case likedByUser = "liked_by_user"
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


// MARK: - Urls

struct Urls: Decodable {
    let raw, full, regular, small: String
    let thumb, smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

//
//  URLBuilder.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 29.10.2023.
//

import Foundation

//MARK: - Construct

enum URLScheme: String {
    case http
    case https
}

enum URLHost: String {
    case main = "api.unsplash.com"
}

enum APIPath: String {
    case getPhotos = "/photos"
    case getRandomPhotos = "/photos/random"
    case searchPhotos = "/search/photos"
}

//MARK: - Builder

struct URLBuilder {
    
    static func buildURL(with
                         scheme: URLScheme,
                         host: URLHost,
                         path: APIPath,
                         queryItems: [URLQueryItem]) -> URL? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme.rawValue
        urlComponents.host = host.rawValue
        urlComponents.path = path.rawValue
        urlComponents.queryItems = queryItems
        
        return URL(string: urlComponents.string!)
    }
}

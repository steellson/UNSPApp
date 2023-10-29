//
//  URLBuilder.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 29.10.2023.
//

import Foundation

enum URLScheme: String {
    case http
    case https
}

enum URLHost: String {
    case main = "api.unsplash.com"
}

enum APIPath: String {
    case getPhotos = "/photos"
}

struct PaginationArguments {
    
    enum ArgumentNames: String {
        case per_page
        case page
    }
    
    var perPage: Int
    var currentPage: Int
}

struct URLBuilder {
    
    static func buildURL(with
                         scheme: URLScheme,
                         host: URLHost,
                         path: APIPath,
                         queryItems: [URLQueryItem]
    ) -> URL? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme.rawValue
        urlComponents.host = host.rawValue
        urlComponents.path = path.rawValue
        urlComponents.queryItems = queryItems
        
        return URL(string: urlComponents.string!)
    }
}

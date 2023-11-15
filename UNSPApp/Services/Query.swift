//
//  Query.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 15.11.2023.
//

import Foundation

//MARK: - Impl

final class Query {
    
    //MARK: Select
    enum ArgumentName: String {
        case per_page
        case page
        case query
        case count
    }

    
    //MARK: Defaults
    var perPage: Int
    var currentPage: Int
    var queryText: String?
    var count: Int
    
    
    //MARK: Init
    init(
        perPage: Int = 10,
        currentPage: Int = 1,
        queryText: String? = nil,
        count: Int = 3
    ) {
        self.perPage = perPage
        self.currentPage = currentPage
        self.queryText = queryText
        self.count = count
    }
}

//MARK: - Conveniance initialization

extension Query {
    
    //MARK: Pagination
    convenience init(perPage: Int, page: Int) {
        self.init()
        self.perPage = perPage
        self.currentPage = page
    }
    
    //MARK: Random count
    convenience init(count: Int) {
        self.init()
        self.count = count
    }
    
    //MARK: Search
    convenience init(perPage: Int, queryText: String) {
        self.init()
        self.perPage = perPage
        self.queryText = queryText
    }
}

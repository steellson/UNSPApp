//
//  Query.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 15.11.2023.
//

import Foundation

//MARK: - Impl

final class Query {
    
    let pagesAmountValue = 20
    
    //MARK: Select
    enum ArgumentName: String {
        case per_page
        case page
        case query
        case count
        case ordered_by
    }

    enum OrderSelection: String {
        case latest
        case relevant
    }
    
    //MARK: Defaults
    var perPage: Int
    var perPageSearch: Int
    var currentPage: Int
    var queryText: String?
    var count: Int
    var orderedBy: OrderSelection?
    
    
    //MARK: Init
    init(
        perPage: Int = 10,
        perPageSearch: Int = 5,
        currentPage: Int = 1,
        queryText: String? = nil,
        count: Int = 3,
        orderedBy: OrderSelection = .latest
    ) {
        self.perPage = perPage
        self.perPageSearch = perPageSearch
        self.currentPage = currentPage
        self.queryText = queryText
        self.count = count
        self.orderedBy = orderedBy
    }
}

//MARK: - Conveniance initialization

extension Query {
    
    //MARK: Pagination
    convenience init(
        perPage: Int,
        page: Int
    ) {
        self.init()
        self.perPage = perPage
        self.currentPage = page
    }
    
    //MARK: Random count
    convenience init(
        count: Int
    ) {
        self.init()
        self.count = count
    }
    
    //MARK: Search
    convenience init(
        perPageSearch: Int,
        queryText: String,
        orderedBy: Query.OrderSelection
    ) {
        self.init()
        self.perPageSearch = perPageSearch
        self.queryText = queryText
        self.orderedBy = orderedBy
    }
}

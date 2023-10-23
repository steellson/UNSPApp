//
//  APIService.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation
import Moya

//MARK: - Protocol

protocol APIServiceProtocol: AnyObject {
    
}


//MARK: - Impl

final class APIService {
    
    let apiProvider: MoyaProvider<UnspashAPI>
    
    private let accessKey = R.Strings.apiAccessKey.rawValue
    
    init(
        apiProvider: MoyaProvider<UnspashAPI>
    ) {
        self.apiProvider = apiProvider
    }
    
}

//MARK: - Protocol extension

extension APIService: APIServiceProtocol {
    
}

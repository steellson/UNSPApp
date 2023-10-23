//
//  UnspashAPI.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation
import Moya

public enum UnspashAPI {
    case fetchImages
}

extension UnspashAPI: TargetType {
    
    public var baseURL: URL {
        URL(string: "\(R.Strings.baseUrlString.rawValue)/v1")!
    }
    
    public var path: String {
        switch self {
        case .fetchImages: ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .fetchImages: return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .fetchImages: return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .fetchImages:
            return [
                "" : ""
            ]
        }
    }
}

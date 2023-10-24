//
//  Client.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 24.10.2023.
//

import Foundation

struct Client: Encodable {
    
    let clientID: String
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
    }
}

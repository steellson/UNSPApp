//
//  Resources.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation
import UIKit

//MARK: APP RESOURCES


enum R {
    
    //MARK: - Strings
    enum Strings: String {
        
        // Title strings
        case mainScreenTitle = "Pick some image for details ..."
        
        // API
        case apiAccessKey = "JhHk7WPduzX_0Mn0aaJ8qjU4ZQzdGc5-Q7y4388lhk8"
        case baseUrlString = "https://api.unsplash.com"
        
        // Identity
        case imageCellIdentifier = "imageCellIdentifier"
        
        // Log messages
        case photosFetched = "SUCCESS: Photos fetched succsessfully!"
        case photoFetched = "SUCCESS: Photo downloaded succsessfully!"
        case photoDataSourceUpdated = "--- MainViewModel photos data updated! ---"
    }
    
    
    //MARK: - Colors
    enum Colors {
        static let primaryBackgroundColor = UIColor.init(red: 200/255, green: 211/255, blue: 3/255, alpha: 1)
    }
}

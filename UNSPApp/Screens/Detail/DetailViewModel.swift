//
//  DetailViewModel.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import Foundation


//MARK: - Impl

final class DetailViewModel {
    
    private let imageData: Data
    
    init(
        imageData: Data
    ) {
        self.imageData = imageData
    }
    
    
    func getImageData() -> Data {
        imageData
    }
}

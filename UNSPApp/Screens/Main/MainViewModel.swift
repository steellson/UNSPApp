//
//  MainViewModel.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    
}


//MARK: - Impl

final class MainViewModel {
    
    private let apiService: APIServiceProtocol
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
    }
}

//MARK: - Protocol extension

extension MainViewModel: MainViewModelProtocol {
    
}

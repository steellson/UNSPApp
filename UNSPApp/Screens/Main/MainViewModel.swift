//
//  MainViewModel.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - State

enum MainViewModelState {
    case normal
    case loading
    case error
}

//MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    func getPhotos()
}


//MARK: - Impl

final class MainViewModel {
    
    @Published var state: MainViewModelState = .normal
    
    @Published var photos = [Photo]() {
        didSet {
            guard !photos.isEmpty else { return }
            print("MainViewModel photos data setted!\n\(photos)")
        }
    }
    
    private let apiService: APIServiceProtocol
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
    }
}

//MARK: - Protocol extension

extension MainViewModel: MainViewModelProtocol {
    func getPhotos() {
        guard state != .loading else {
            print("ERROR: Couldnt start loading beceuse it is already started"); return
        }
        state = .loading
        photos = []
        
        apiService.fetchPhotos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    self?.photos = photos
                    self?.state = .normal
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.photos = []
                    self?.state = .error
                }
            }
        }
    }
}

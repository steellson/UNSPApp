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
    var photos: [Photo] { get }
    func getAllPhotos()
    func getConcretePhoto(fromURL url: String, completion: @escaping (Result<Data, Error>) -> Void)
}


//MARK: - Impl

final class MainViewModel {
    
    @Published var state: MainViewModelState = .normal
    
    @Published private(set) var photos = [Photo]() {
        didSet {
            guard !photos.isEmpty else { return }
            print("MainViewModel photos data setted!")
        }
    }
    
    private let apiService: APIServiceProtocol
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
        
        getAllPhotos()
    }
}

//MARK: - Protocol extension

extension MainViewModel: MainViewModelProtocol {
    
    func getAllPhotos() {
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
    
    func getConcretePhoto(fromURL url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard state != .loading else {
            print("ERROR: Couldnt start loading beceuse it is already started"); return
        }
        state = .loading
        
        apiService.downloadPhoto(fromURL: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(.success(data))
                    self?.state = .normal
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                    self?.state = .error
                }
            }
        }
    }
}

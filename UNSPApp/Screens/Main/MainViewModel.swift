//
//  MainViewModel.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation

//MARK: - State

enum MainViewModelState {
    case none
    case normal
    case loading
    case error
}

//MARK: - Protocol

protocol MainViewModelProtocol: AnyObject {
    var state: MainViewModelState { get }
    var photos: [Photo] { get }
    var paginationArguments: Query { get set }

    func getAllPhotos()
    func getConcretePhoto(fromURL url: String?, completion: @escaping (Result<Data, Error>) -> Void)
    func searchPhotos(withText text: String)
}


//MARK: - Impl

final class MainViewModel {
    
    var paginationArguments = Query(perPage: 10, currentPage: 1)
    
    private(set) var state: MainViewModelState = .none {
        didSet {
            if state != oldValue {
                print("MainViewModel current state = \(state)")
            }
        }
    }
    
    private(set) var photos = [Photo]() {
        didSet {
            guard !photos.isEmpty else { return }
            print(R.Strings.photoDataSourceUpdated.rawValue)
        }
    }
    
    private let apiService: APIServiceProtocol
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
        
//        #warning("Data fetching is turned off")
//        getAllPhotos()
        
    }
}

//MARK: - Protocol extension

extension MainViewModel: MainViewModelProtocol {
    
    func getAllPhotos() {
        
        if state != .loading {
            state = .loading
        }
        print("Loading photos from page: \(paginationArguments.currentPage)")

        apiService.fetchPhotos(withParameters: paginationArguments) { [weak self] result in
                switch result {
                case .success(let photos):
                    self?.photos += photos.sorted(by: { $0.height < $1.height })
                    self?.state = .normal
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.photos = []
                    self?.state = .error                    
                }
        }
    }
    
    func getConcretePhoto(fromURL url: String?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url else {
            print("ERROR: Couldnt get url"); return
        }
        
        if state != .loading {
            state = .loading
        }

        apiService.downloadPhoto(fromURL: url) { [weak self] result in
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
    
    func searchPhotos(withText text: String) {
        guard !text.isEmpty, text.count > 1 else { return }
        
        if state != .loading {
            state = .loading
        }
        
        apiService.searchPhoto(
            withText: text,
            itemsPerPage: 20
        ) { [weak self] result in
            
            switch result {
            case .success(let photos):
                self?.photos = photos
                self?.state = .normal
            case .failure(let error):
                print(error.localizedDescription)
                self?.state = .error
            }
        }
    }
}

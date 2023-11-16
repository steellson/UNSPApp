//
//  MainViewModel.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import Foundation
import Combine

//MARK: - State

enum MainViewModelState {
    case none
    case normal
    case loading
    case error
}

//MARK: - Impl

final class MainViewModel {
    
    var queryParameters = Query()
    
    private(set) var state: MainViewModelState = .none {
        didSet {
            if state != oldValue {
                print("MainViewModel current state = \(state)")
            }
        }
    }
    
    @Published private(set) var photos = [Photo]() {
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
        
        setupQueryParameters()
        
        getAllPhotos()
    }
    
        
    private func setupQueryParameters() {
        queryParameters.perPage = 3
        queryParameters.currentPage = 4
    }
}


//MARK: - Public Methods

extension MainViewModel {
    
    //MARK: Get all photos
    func getAllPhotos() {
        
        if state != .loading {
            state = .loading
        }
        print("Loading photos from page: \(queryParameters.currentPage)")

        apiService.fetchPhotos(
            withParameters: queryParameters
        ) { [weak self] result in
            
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

    
    //MARK: Get concrete photo
    func getConcretePhoto(fromURL url: String?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url else {
            print("ERROR: Couldnt get url"); return
        }
        
        if state != .loading {
            state = .loading
        }

        apiService.downloadPhoto(
            fromURL: url)
        { [weak self] result in
            
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
    
    //MARK: Search photos
    func searchPhotos(withText text: String, itemsPerPage: Int) {
        guard !text.isEmpty, text.count > 1 else { return }
        
        if state != .loading {
            state = .loading
        }
        
        apiService.searchPhoto(
            withText: text,
            itemsPerPage: itemsPerPage
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

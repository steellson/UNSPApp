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


final class MainViewModel {
    
    //MARK: Input/Output
    
    struct Input {
        let viewDidLoadedPublisher: AnyPublisher<Void, Never>
        let searchQueryTextPublisher: AnyPublisher<String?, Never>
    }
    
    struct Output {
        let viewDidLoadedPublisher: AnyPublisher<Void, Never>
        let searchQueryTextPublisher: AnyPublisher<Void, Never>
        let setDataSourcePublisher: AnyPublisher<[Photo], Never>
    }
    
    enum OutputVoid {
        case didLoadedPublisher
        case queryTextPublisher
    }
    
    
    //MARK: Variables
    
    var queryParameters = Query()
    
    @Published var queryText: String? = nil
    
    @Published private(set) var photos = [Photo]() {
        didSet {
            guard !photos.isEmpty else { return }
            print(R.Strings.photoDataSourceUpdated.rawValue)
        }
    }
        
    private(set) var state: MainViewModelState = .none {
        didSet {
            if state != oldValue {
                print("MainViewModel current state = \(state)")
            }
        }
    }
    
    private let apiService: APIServiceProtocol
    
    
    //MARK: Init
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
        
        setupQueryParameters()
        getAllPhotos()
    }
}


//MARK: - Private methods

private extension MainViewModel {
    
    func eraseToAnyPublusher(_ input: Input,
                             withType type: OutputVoid) -> AnyPublisher<Void, Never> {
        switch type {
        case .didLoadedPublisher: return input
                .viewDidLoadedPublisher
                .handleEvents(
                    receiveOutput:  { [weak self] _ in
                        self?.getAllPhotos()
                    }
                )
                .flatMap { Just(()) }
                .eraseToAnyPublisher()
        case .queryTextPublisher: return input
                .searchQueryTextPublisher
                .handleEvents(
                    receiveOutput:  { [weak self] queryText in
                        self?.queryText = queryText
                    }
                )
                .flatMap { _ in Just(()) }
                .eraseToAnyPublisher()
                        
        }
    }
    
    func setupQueryParameters() {
        queryParameters.perPage = 12
        queryParameters.perPageSearch = 5
        queryParameters.currentPage = 1
        queryParameters.orderedBy = .latest
    }
}


//MARK: - Public methods

extension MainViewModel {
    
    func transform(input: Input) -> Output {
        
        let viewDidLoadedPublisher = eraseToAnyPublusher(input, withType: .didLoadedPublisher)
        let searchQueryTextPublisher = eraseToAnyPublusher(input, withType: .queryTextPublisher)
        let setDataSourcePublisher = Publishers.CombineLatest(
            $photos.compactMap { $0 },
            $queryText
        )
            .flatMap { (photos: [Photo], queryText: String?) in
                if let queryText = queryText, !queryText.isEmpty {
                    let filteredPhotos = photos.filter {
                        $0.description?
                            .lowercased()
                            .contains(queryText)
                        ?? $0.slug
                            .replacing("-", with: " ")
                            .contains(queryText)
                    }
                    return Just(filteredPhotos)
                } else {
                    return Just(photos)
                }
            }
            .eraseToAnyPublisher()
        
        return Output(
            viewDidLoadedPublisher: viewDidLoadedPublisher,
            searchQueryTextPublisher: searchQueryTextPublisher,
            setDataSourcePublisher: setDataSourcePublisher
        )
    }
    
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
    func searchPhotos(withText text: String) {
        guard !text.isEmpty, text.count > 1 else { return }
        
        if state != .loading {
            state = .loading
        }
        
        apiService.searchPhoto(
            withText: text,
            itemsPerPage: queryParameters.perPageSearch,
            orderedBy: queryParameters.orderedBy ?? .latest
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

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
        let searchQueryTextPublisher: AnyPublisher<String?, Never>
    }
    
    struct Output {
        let setDataSourcePublisher: AnyPublisher<[Photo], Never>
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
    
    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: Init
    
    init(
        apiService: APIServiceProtocol
    ) {
        self.apiService = apiService
        
        setupQueryParameters()
        getAllPhotos()
    }

    
    func setupQueryParameters() {
        queryParameters.perPage = 10
        queryParameters.perPageSearch = 10
        queryParameters.currentPage = 1
        queryParameters.orderedBy = .latest
    }
}

//MARK: - Reactive

extension MainViewModel {
    
    func transform(input: Input) -> Output {
        subscribeOnQueryText(withInput: input)
        
        return Output(
            setDataSourcePublisher: $photos.eraseToAnyPublisher()
        )
    }
    
    private func subscribeOnQueryText(withInput input: Input) {
        input
            .searchQueryTextPublisher
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] queryText in
                    if queryText == "" {
                        self?.photos = []
                        self?.getAllPhotos()
                    } else {
                        self?.searchPhotos(withText: queryText)
                    }
                }
            .store(in: &cancellables)
            
    }
}

//MARK: - Public methods

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

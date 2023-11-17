//
//  MainViewController.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import UIKit
import SnapKit
import Combine


//MARK: - Impl

final class MainViewController: BaseController {
    
    private var viewModel: MainViewModel
    
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    
    private var collectionViewLayout = CustomLayout()
    private var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    private var viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private var queryTextSubject = PassthroughSubject<String?, Never>()

    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: Init
    
    init(
        viewModel: MainViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Setup
    
    private func setupTitleLabel() {
        titleLabel.text = R.Strings.mainScreenTitle.rawValue
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.shadowColor = .gray
        titleLabel.shadowOffset = .init(width: 0.5, height: 1)
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = R.Strings.searchBarPlaceholder.rawValue
        searchController.searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.5)
        searchController.searchBar.tintColor = .black
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = true
        
        let searchResultController = searchController.searchResultsController
        searchResultController?.view.backgroundColor = R.Colors.primaryBackgroundColor
    }
    
    private func setupCollectionView(withLayout layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = false
        collectionView.prefetchDataSource = self
        collectionView.isPrefetchingEnabled = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.imageCellIdentifier)
    }
    
    private func setupDelegates() {
        collectionViewLayout.delegate = self
        collectionView.delegate = self
    }
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        setupTitleLabel()
        setupSearchController()
        setupCollectionView(withLayout: collectionViewLayout)
        setupDataSource()
        setupDelegates()
        viewDidLoadSubject.send()
        view.addNewSubview(titleLabel)
        view.addNewSubview(collectionView)
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        navigationItem.titleView = titleLabel
        navigationItem.searchController = searchController
    }
    
    override func setupLayout() {
        super.setupLayout()
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchController.searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func setupBindings() {
        super.setupBindings()
        observe()
    }
}

//MARK: - DataSource + Snapshot

private extension MainViewController {
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, photo) -> UICollectionViewCell? in
                
                guard let imageCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCell.imageCellIdentifier,
                    for: indexPath
                ) as? ImageCell else {
                    print("ERROR: Couldnt dequeue cell with reuse identifier"); return UICollectionViewCell()
                }
                
                self.viewModel.getConcretePhoto(fromURL: photo.urls.thumb) { result in
                    switch result {
                    case .success(let imageData):
                        guard let recievedImage = UIImage(data: imageData) else {
                            print("ERROR: Couldt get recieved image"); return
                        }
                        
                        imageCell.configureCell(withImage: recievedImage)
                    case .failure:
                        print("ERROR: Couldnt download image")
                    }
                }
                return imageCell
            })
    }
    
    func updateSnapshot(withPhotos photos: [Photo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - Delegates

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        collectionView.layoutIfNeeded()
        print("Selected: \(indexPath.item) / collectionView layout reloaded")
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let currentPage = viewModel.queryParameters.currentPage
        let limitPage = viewModel.queryParameters.pagesAmountValue
        let triggerValue = viewModel.photos.count - 2
        
        if indexPath.item == triggerValue && currentPage <= limitPage {
            viewModel.queryParameters.currentPage += 1
            viewModel.getAllPhotos()
        }
    }
}

extension MainViewController: CustomLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let receivedImageSize = CGSize(
            width: viewModel.photos[indexPath.item].width,
            height: viewModel.photos[indexPath.item].height
        )
        let screenWidth = UIScreen.main.bounds.width / 2
        return (receivedImageSize.height / receivedImageSize.width) * screenWidth
    }
}

//extension MainViewController: UISearchBarDelegate {
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//
//    }
//}

//MARK: - Prefetching

extension MainViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach {
            if $0.item >= (viewModel.photos.count - 3) {
                viewModel.queryParameters.currentPage += 1
                viewModel.getAllPhotos()
            }
        }
    }
}

//MARK: - Search

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let searchText = searchController.searchBar.text,
            !searchText.isEmpty,
            searchText.count > 1
        else {
            return
        }
        
        queryTextSubject.send(searchText)
        
//        let itemsPerPage = viewModel.queryParameters.pagesAmountValue
//        
//        viewModel.searchPhotos(
//            withText: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
//            itemsPerPage: itemsPerPage
//        )
    }
}


//MARK: - Observing

private extension MainViewController {
    
    func observe() {
        
        let input = MainViewModel.Input(
            viewDidLoadedPublisher: viewDidLoadSubject.eraseToAnyPublisher(),
            searchQueryTextPublisher: queryTextSubject.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)
        
        [output.viewDidLoadedPublisher, output.searchQueryTextPublisher].forEach {
            $0.sink(receiveValue: { _ in  }).store(in: &cancellables)
        }
        
        output.setDataSourcePublisher
            .drop(while: { $0.count < 1 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                DispatchQueue.main.async {
                    self?.updateSnapshot(withPhotos: photos)
                }
            }
            .store(in: &cancellables)
    }
}

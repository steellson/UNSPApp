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
    
    private var viewModel: MainViewModelProtocol
    
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    private lazy var collectionView = makeCollectionView()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    private var cancellables = Set<AnyCancellable>()

    
    //MARK: Init
    
    init(
        viewModel: MainViewModelProtocol
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
        searchController.obscuresBackgroundDuringPresentation = false
        
        let searchResultController = searchController.searchResultsController
        searchResultController?.view.backgroundColor = R.Colors.primaryBackgroundColor
    }
    
    
    //MARK: Make CV
    
    private func makeFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return flowLayout
    }
        
    private func makeCollectionView() -> UICollectionView {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeFlowLayout())
        cv.layer.cornerRadius = 10
        cv.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        cv.contentInsetAdjustmentBehavior = .never
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.prefetchDataSource = self
        cv.isPrefetchingEnabled = true
        cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.imageCellIdentifier)
        return cv
    }
    
    
    //MARK: - Methods
    
    private func calculateCellHeight(ofCollectionViewCell collectionView: UICollectionView,
                                     indexPath: IndexPath, 
                                     width: CGFloat) -> CGSize {
        let imageHeight = CGFloat(viewModel.photos[indexPath.item].height)
        let height = imageHeight / 30
        
        return CGSize(width: width, height: height)
    }
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        setupDataSource()
        setupTitleLabel()
        setupSearchController()
        
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
        bindPhotoCollection()
    }
}

//MARK: - DataSource + Snapshot

private extension MainViewController {
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, photo) -> UICollectionViewCell? in
                
                guard let imageCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCell.imageCellIdentifier,
                    for: indexPath
                ) as? ImageCell else {
                    print("ERROR: Couldnt dequeue cell with reuse identifier"); return UICollectionViewCell()
                }
                
                //MARK: Download image (SMALL)
                self?.viewModel.getConcretePhoto(fromURL: photo.urls.small) { result in
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

//MARK: - Delegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath.item) / collectionView layout reloaded")
        collectionView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (viewModel.photos.count - 2) {
            viewModel.paginationArguments.currentPage += 1
            viewModel.getAllPhotos()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateCellHeight(ofCollectionViewCell: collectionView,
                                   indexPath: indexPath,
                                   width: (UIScreen.main.bounds.size.width / 2) - 0.1) 
    }
}

//MARK: - Prefetching

extension MainViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            if $0.item >= (viewModel.photos.count - 3) {
                viewModel.paginationArguments.currentPage += 1
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
        else { return }

        DispatchQueue.main.async { [weak self] in
            self?.viewModel.searchPhotos(withText: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}


//MARK: - Bindings

private extension MainViewController {
    
    func bindPhotoCollection() {
        
        viewModel.photos
            .publisher
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                DispatchQueue.main.async {
                    self?.updateSnapshot(withPhotos: photos)
                    self?.collectionView.reloadData()
                    self?.collectionView.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
}

//
//  MainViewController.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import UIKit
import SnapKit
import Combine

typealias DataSource = UICollectionViewDiffableDataSource<Section, Photo>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Photo>

//MARK: - Impl

class MainViewController: BaseController {
    
    private let titleLabel = UILabel()
    private let searchController = UISearchController()
    private var collectionView: UICollectionView!
    private var collectionViewLayout = CustomLayout()
    
    private var dataSource: DataSource!
    
    private var viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private var queryTextSubject = PassthroughSubject<String?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: MainViewModel
    
    private var selectedCell: ImageCell?
    
    private var startingAnimationPoint: CGPoint {
        let centerPoint = self.collectionView.center
        let collectionViewYOffeset = self.collectionView.frame.origin.y
        
        return CGPoint(
            x: centerPoint.x,
            y: centerPoint.y + collectionViewYOffeset
        )
    }
    
    
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    private func setupSearchCancelButtonVisability() {
        guard let queryText = viewModel.queryText else { return }
        let searchIsActive = searchController.isActive
        let isButtonShown = queryText.isEmpty && searchIsActive
        
        searchController.searchBar.showsCancelButton = isButtonShown
    }
    
    private func setupCollectionView(withLayout layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = false
        collectionView.prefetchDataSource = self
        collectionViewLayout.delegate = self
        collectionView.isPrefetchingEnabled = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.imageCellIdentifier)
    }
    
    private func subscribeForTransitionToDetail(fromCell cell: ImageCell) {
        cell.didTapSubject.sink(receiveValue: { [weak self] photo, indexPath in
            
            // Transition point preparing
            guard
                let cellForIndexPath = self?.collectionView.cellForItem(at: indexPath) as? ImageCell
            else { return }
            self?.selectedCell = cellForIndexPath
            
            // Transition
            let detailModule = Assembly.builder.build(module: .detail(photo))
            detailModule.transitioningDelegate = self
            detailModule.modalPresentationStyle = .custom
            self?.present(detailModule, animated: true)
        })
        .store(in: &cell.cancellables)
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

//MARK: - Observing

private extension MainViewController {
    
    func observe() {
        
        let input = MainViewModel.Input(searchQueryTextPublisher: queryTextSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.searchQueryTextPublisher
            .sink { [weak self] _ in
                self?.setupSearchCancelButtonVisability()
            }
            .store(in: &cancellables)
        
        output.setDataSourcePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self?.updateSnapshot(withPhotos: photos)
                    }
                }
            }
            .store(in: &cancellables)
        
        output.quitFromSearch
            .sink { textIsEmpty in
                if textIsEmpty {
                    print("Searh text is empty!")
                }
            }
            .store(in: &cancellables)
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
                    print("ERROR: Couldnt dequeue image cell with reuse identifier"); return UICollectionViewCell()
                }
                
                //MARK: Download image data (SMALL)
                self?.viewModel.getConcretePhoto(fromURL: photo.urls.small) { result in
                    
                    switch result {
                    case .success(let imageData):
                        guard let recievedImage = UIImage(data: imageData) else {
                            print("ERROR: Couldt get recieved image"); return
                        }
                        imageCell.configureCell(
                            withImage: recievedImage,
                            indexPath: indexPath
                        )
                    case .failure:
                        print("ERROR: Couldnt download image")
                    }
                }
                
                //MARK: Tap reaction / Transition
                self?.subscribeForTransitionToDetail(fromCell: imageCell)
                
                return imageCell
            })
    }
    
    func updateSnapshot(withPhotos photos: [Photo]) {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}


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


//MARK: - Search Results Updating

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        
        if let queryText = searchController.searchBar.text {
            queryTextSubject.send(queryText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}


//MARK: - Custom Layout Delegate

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

//MARK: - Transitioning Delegate

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomTransition(
            transitionType: .present,
            duration: 0.5,
            statringPoint: startingAnimationPoint
        )
    }
    
    func animationController(forDismissed
                             dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomTransition(
            transitionType: .dismiss,
            duration: 0.5,
            statringPoint: startingAnimationPoint
        )
    }
}

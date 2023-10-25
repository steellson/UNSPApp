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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textAlignment = .left
        label.text = R.Strings.mainScreenTitle.rawValue
        label.shadowColor = .gray
        label.shadowOffset = .init(width: 0.5, height: 1)
        return label
    }()
    
    private lazy var collectionView = makeCollectionView()

    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        viewModel: MainViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.imageCellIdentifier)
        
        return cv
    }
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        
        view.addNewSubview(titleLabel)
        view.addNewSubview(collectionView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        guard let screenSize = view.window?.windowScene?.screen.bounds else {
            print("ERROR: Couldnt get screen size"); return
        }
        let topMargin = screenSize.height * 0.01
        let sideMargins = screenSize.width * 0.02
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(topMargin)
            $0.leading.trailing.equalToSuperview().inset(sideMargins)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        bind()
    }
}

//MARK: - DataSource

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.imageCellIdentifier,
            for: indexPath
        ) as? ImageCell else {
            print(); return UICollectionViewCell()
        }
        
        viewModel.getConcretePhoto(fromURL: viewModel.photos[indexPath.item].links.download) { result in
            switch result {
            case .success(let imageData):
                guard let recievedImage = UIImage(data: imageData) else {
                    print("ERROR: Couldt get recieved image"); return
                }
                imageCell.configureCell(withImage: recievedImage)
            case .failure:
                guard let systemImage = UIImage(systemName: "bandage") else {
                    print("ERROR: Couldt get system image"); return
                }
                imageCell.configureCell(withImage: systemImage)
            }
        }
        
        return imageCell
    }
}

//MARK: - Delegates

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath.item)")
    }
}

//MARK: - Bindings

private extension MainViewController {
    
    func bind() {
        
        viewModel.photos
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                
            guard self?.viewModel.state == .normal else {
                print("ERROR: ViewModel state is not in normal selection"); return
            }
                        
            self?.viewModel.getConcretePhoto(fromURL: photo.links.download, completion: { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        print("ERROR: Couldnt convert image from data!"); return
                    }
                    
                    print("SUCCESS: Image setted!")
                case .failure(let error):
                    print("ERROR: Couldnt get photo on VC \(error.localizedDescription)")
                }
            })
        }
        .store(in: &cancellables)
    }
}

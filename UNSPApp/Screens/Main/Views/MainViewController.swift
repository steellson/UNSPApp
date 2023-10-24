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
    
    private var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
}


//MARK: - Base

extension MainViewController {
    
    override func setupView() {
        super.setupView()
        
        view.addNewSubview(imageView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(200)
            $0.center.equalToSuperview()
        }
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        bind()
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
                    self?.imageView.image = image
                    print("SUCCESS: Image setted!")
                case .failure(let error):
                    print("ERROR: Couldnt get photo on VC \(error.localizedDescription)")
                }
            })
        }
        .store(in: &cancellables)
    }
}

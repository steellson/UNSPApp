//
//  MainViewController.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 23.10.2023.
//

import UIKit
import SnapKit

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
        
        view.backgroundColor = R.Colors.primaryBackgroundColor
        view.addSubview(imageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            self?.testImageDownloading()
        }
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(200)
            $0.center.equalToSuperview()
        }
    }
}

//MARK: - Manage

private extension MainViewController {
    
    func testImageDownloading() {
        let photoURL = viewModel.photos[0].links.download

        viewModel.getConcretePhoto(fromURL: photoURL) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else {
                        print("ERROR: Couldt get image from data on VC"); return
                    }
                    self?.imageView.image = image
                }
            case .failure(let error):
                print("Photo does not settupped in imageView, error - \(error)")
            }
        }
    }
    
}

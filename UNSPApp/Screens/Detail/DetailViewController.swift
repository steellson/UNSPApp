//
//  DetailViewController.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import UIKit


//MARK: - Impl

final class DetailViewController: BaseController {
    
    private let viewModel: DetailViewModel
    
    private let tapGesture = UITapGestureRecognizer()
    private let imageView = UIImageView()
    
    
    //MARK: - Init
    
    init(
        viewModel: DetailViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Setup
    
    private func setupContentView() {
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.addGestureRecognizer(tapGesture)
        view.addSubview(imageView)
    }
    
    private func setupTapGesture() {
        tapGesture.addTarget(self, action: #selector(didTapped))
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        
        let imageData = viewModel.getImageData()
        imageView.image = convertImage(fromData: imageData)
    }
    
    private func convertImage(fromData data: Data) -> UIImage {
        UIImage(data: data) ?? UIImage(named: "ximage")!
    }
    
    @objc private func didTapped() {
        self.dismiss(animated: true)
    }
}


//MARK: - Base

extension DetailViewController {
    
    override func setupView() {
        super.setupView()
        setupContentView()
        setupTapGesture()
        setupImageView()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        imageView.frame = CGRect(
            x: .zero,
            y: .zero,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }
}


//MARK: - Observe

private extension DetailViewController {
    
}

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
        view.addSubview(imageView)
    }
    
    private func setupTapGesture() {
        
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(tapGesture)
    }
    
    private func setDelegates() {
        
    }
}


//MARK: - Base

extension DetailViewController {
    
    override func setupView() {
        super.setupView()
        setupContentView()
        setupTapGesture()
        setupImageView()
        setDelegates()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        imageView.frame = CGRect(
            x: view.center.x,
            y: view.center.y,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }
}


//MARK: - Observe

private extension DetailViewController {
    
}

//MARK: - Transitioning Delegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
}

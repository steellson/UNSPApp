//
//  ImageCell.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 25.10.2023.
//

import Foundation
import UIKit
import SnapKit
import Combine


//MARK: - Impl

final class ImageCell: BaseCell {

    static let imageCellIdentifier = R.Strings.imageCellIdentifier.rawValue
    
    private let tapRecognizer = UITapGestureRecognizer()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let imageView = UIImageView()
    
    var didTapSubject = PassthroughSubject<Data, Never>()
    var cancellables = Set<AnyCancellable>()
    
    
    
    func configureCell(withImage image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.setupActivityIndicator()
        }
    }
    
    
    //MARK: Setup
    
    private func setupContentView() {
        contentView.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addGestureRecognizer(tapRecognizer)
        contentView.addNewSubview(activityIndicator)
        contentView.addNewSubview(imageView)
    }
    
    private func setupActivityIndicator() {
        if imageView.image == nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
    }
    
    private func setupTapGesture() {
        tapRecognizer.addTarget(self, action: #selector(didTapped))
    }
    
    @objc private func didTapped() {
        guard let image = imageView.image,
              let data = image.jpegData(compressionQuality: 1)
        else { return }
            
        didTapSubject.send(data)
    }
}
            
//MARK: - Base

extension ImageCell {
    
    override func setupCell() {
        super.setupCell()
        setupContentView()
        setupImageView()
        setupActivityIndicator()
        setupTapGesture()
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func clearCell() {
        super.clearCell()
        cancellables.removeAll()
    }
}

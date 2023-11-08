//
//  ImageCell.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 25.10.2023.
//

import Foundation
import UIKit
import SnapKit

//MARK: - Impl

final class ImageCell: BaseCell {
    
    static let imageCellIdentifier = R.Strings.imageCellIdentifier.rawValue
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let imageView = ResizableImageView(frame: .zero)
    

    func configureCell(withImage image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.imageView.invalidateIntrinsicContentSize()
            self?.setupActivityIndicator()
        }
    }
    
    
    //MARK: Setup
    
    private func setupContentView() {
        contentView.backgroundColor = .systemBackground.withAlphaComponent(0.2)
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
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
}


//MARK: - Base

extension ImageCell {
    
    override func setupCell() {
        super.setupCell()
        setupActivityIndicator()
        setupContentView()
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func clearCell() {
        super.clearCell()
        imageView.image = UIImage(named: "bandage")
    }
}


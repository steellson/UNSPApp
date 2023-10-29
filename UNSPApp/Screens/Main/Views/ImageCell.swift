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
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "bandage")
        iv.tintColor = .black
        return iv
    }()
    
    private var imageViewWidth: CGFloat {
        (UIScreen.main.bounds.size.width / 2) - 0.1
    }
    
//    var hConst: NSLayoutConstraint {
//        .init(
//            item: imageView,
//            attribute: .height,
//            relatedBy: .equal,
//            toItem: nil,
//            attribute: .notAnAttribute,
//            multiplier: 1,
//            constant: 10
//        )
//    }

    func configureCell(withImage image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.contentView.frame = .init(
                x: self?.center.x ?? .zero,
                y: self?.center.y ?? .zero,
                width: UIScreen.main.bounds.width / 2,
                height: image.size.height
            )
            self?.contentView.invalidateIntrinsicContentSize()
            
            self?.setupActivityIndicator()
        }
    }
    
    private func setupActivityIndicator() {
        imageView.image == nil
        ? activityIndicator.startAnimating()
        : activityIndicator.stopAnimating()
    }
}


//MARK: - Base

extension ImageCell {
    
    override func setupCell() {
        super.setupCell()
        setupActivityIndicator()
        
        contentView.backgroundColor = .systemBackground.withAlphaComponent(0.2)
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.layer.borderWidth = 0.5
        
        contentView.addNewSubview(activityIndicator)
        contentView.addNewSubview(imageView)
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints {
            $0.center.top.leading.equalToSuperview()
            $0.width.equalTo(imageViewWidth)
        }
    }
    
    override func clearCell() {
        super.clearCell()
        imageView.image = UIImage(named: "bandage")
    }
}


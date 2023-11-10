//
//  ImageCell.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 25.10.2023.
//

import Foundation
import UIKit

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
    
    public lazy var imageHeight: CGFloat = {
        guard let image = imageView.image else {
            print("Couldnt get image height in imageCell!"); return .zero
        }
        return image.size.height
    }()
    
    
    func configureCell(withImage image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.setupActivityIndicator()
        }
    }
    
    
    //MARK: Setup
    
    private func setupFrames() {
        imageView.frame = contentView.bounds
        activityIndicator.frame = CGRect(
            x: contentView.center.x,
            y: contentView.center.y,
            width: 20,
            height: 20
        )
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.frame = imageView.bounds
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
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
        setupFrames()
        setupActivityIndicator()
        setupContentView()
    }
    
    override func clearCell() {
        super.clearCell()
        imageView.image = UIImage(named: "bandage")
    }
}


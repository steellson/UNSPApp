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
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    func configureCell(withImage image: UIImage) {
        self.imageView.image = image
    }
}


//MARK: - Base

extension ImageCell {
    
    override func setupCell() {
        super.setupCell()
        
        contentView.addNewSubview(imageView)
    }
    
    override func setupCellLayout() {
        super.setupCellLayout()
        
    }
}

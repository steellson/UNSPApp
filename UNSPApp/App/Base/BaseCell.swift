//
//  BaseCell.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 25.10.2023.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupCellLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - BaseView Methods Extension

@objc extension BaseCell {
    
    func setupCell() { }
    
    func setupCellLayout() { }
        
    func clearCell() { }
}

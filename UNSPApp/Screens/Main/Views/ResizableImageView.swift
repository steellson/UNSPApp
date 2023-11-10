//
//  ResizableImageView.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 08.11.2023.
//

import UIKit

final class ResizableImageView: UIImageView {
    
    //MARK: Resizability
    override var intrinsicContentSize: CGSize {
        guard let image else { return .zero }
        
        let width = (frame.size.height / image.size.height) * image.size.width
        let height = (frame.size.height / image.size.height) * image.size.height
        
        return .init(width: width,height: height)
    }
    
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    
    //MARK: Setup
    private func setupImageView() {
        clipsToBounds = true
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
        tintColor = .black
    }
}

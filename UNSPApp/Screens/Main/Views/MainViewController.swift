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
        
        viewModel.getPhotos()
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
}

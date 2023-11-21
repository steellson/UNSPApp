//
//  Assembly.swift
//  UNSPApp
//
//  Created by Andrew Steellson on 21.11.2023.
//

import Foundation
import UIKit


//MARK: - Protocol

protocol AssemblyProtocol: AnyObject {
    func build(module: Assembly.Module) -> UIViewController
}


//MARK: - Impl

final class Assembly: AssemblyProtocol {
    
    static let builder = Assembly()
    
    private let services = Services()
    
    
    //MARK: Modules
    
    enum Module {
        case main
        case detail(Data)
    }
    
    
    //MARK: Build
    
    func build(module: Module) -> UIViewController {
        switch module {
            
        case .main:
            let viewModel = MainViewModel(apiService: services.apiService)
            let viewController = MainViewController(viewModel: viewModel)
            return viewController
            
        case .detail(let data):
            let viewModel = DetailViewModel(imageData: data)
            let viewController = DetailViewController(viewModel: viewModel)
            return viewController
        }
    }
}


//MARK: - Services

struct Services {
    let apiService: APIServiceProtocol = APIService()
}

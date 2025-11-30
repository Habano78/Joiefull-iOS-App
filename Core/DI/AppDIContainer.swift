//
//  AppDIContainer.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

//
//  AppDIContainer.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import Combine

class AppDIContainer: ObservableObject {
        
        //MARK: Service injecté
        let networkService: NetworkServiceProtocol
        
        //MARK: Init
        init() {
                self.networkService = NetworkService()
        }
        
        //MARK: Fabriques de ViewModels
        func makeProductListViewModel() -> ProductListViewModel {
                return ProductListViewModel(service: networkService)
        }
        
        func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
                return ProductDetailViewModel(product: product, service: networkService)
        }
}

//
//  AppDIContainer.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import Combine

class AppDIContainer: ObservableObject {
        
        //MARK: SInGLeToN
        let networkService: NetworkServiceProtocol
        
        init() {
                self.networkService = NetworkService()
        }
        
        //MARK: ___ Construction des VIEWMODELS ___
     
        func makeProductListViewModel() -> ProductListViewModel {
                return ProductListViewModel(service: networkService)
        }
        
        func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
                return ProductDetailViewModel(product: product, service: networkService)
        }
        
}


//
//  ViewModel.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    @Published var product: Product
    
    private let service: NetworkServiceProtocol
    
    init(product: Product, service: NetworkServiceProtocol) {
        self.product = product
        self.service = service
    }
    
    // func rateProduct(_ rating: Int) async { ... }
    // func shareProduct() { ... }
}

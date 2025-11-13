//
//  Mock.swift
//  JoiefullTests
//
//  Created by Perez William on 13/11/2025.
//

import SwiftUI
@testable import Joiefull

//MARK: Mock
let mockTestProduct = Product(
        id: 1,
        name: "Test Product",
        category: "TEST",
        likes: 10,
        note: 4.5,
        price: 50.0,
        originalPrice: 100.0,
        picture: Picture(url: "http://test.com", description: "Test Pic")
)

//MARK: faux service

// ... (le mockTestProduct ne change pas)

class MockNetworkService: NetworkServiceProtocol {
        
        //MARK:
        enum MockResult {
                case success
                case failure(Error)
        }
        
        // On configure ce que 'fetchProducts' doit faire
        var fetchProductsResult: MockResult = .success
        
        // On configure ce que 'downloadImage' doit faire
        var downloadImageResult: MockResult = .success
        
        // Compteurs
        var fetchProductsCallCount = 0
        var downloadImageCallCount = 0
        
        
        func fetchProducts() async throws -> [Product] {
                fetchProductsCallCount += 1
                
                switch fetchProductsResult {
                case .success:
                        return [mockTestProduct]
                        
                case .failure(let error):
                        // On lance l'erreur qu'on nous a donnée !
                        throw error
                }
        }
        
        
        func downloadImage(from urlString: String) async throws -> UIImage {
                downloadImageCallCount += 1
                
                try await Task.sleep(nanoseconds: 1_000_000_000) // On garde le délai
                try Task.checkCancellation()
                
                switch downloadImageResult {
                case .success:
                        return UIImage(systemName: "star.fill")!
                        
                case .failure(let error):
                        throw error
                }
        }
}

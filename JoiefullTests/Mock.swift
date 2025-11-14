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
        
        // Configuration de 'fetchProducts'
        var fetchProductsResult: MockResult = .success
        
        // Configuration de'downloadImage'
        var downloadImageResult: MockResult = .success
        
        // Compteurs
        var fetchProductsCallCount = 0
        var downloadImageCallCount = 0
        
        
        func fetchProducts() async throws -> [Product] {
                fetchProductsCallCount += 1
                
                try await Task.sleep(nanoseconds: 500_000_000)/// Simule un  appel réseau (ex: 0.5 sec)
                try Task.checkCancellation()
                
                switch fetchProductsResult {
                case .success:
                        return [mockTestProduct]
                        
                case .failure(let error):
                        throw error
                }
        }
        
        
        func downloadImage(from urlString: String) async throws -> UIImage {
                downloadImageCallCount += 1
                
                try await Task.sleep(nanoseconds: 1_000_000_000) // pour simuler un télechargement
                try Task.checkCancellation()
                
                switch downloadImageResult {
                case .success:
                        return UIImage(systemName: "star.fill")!
                        
                case .failure(let error):
                        throw error
                }
        }
}

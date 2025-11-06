//
//  Preview.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//

import Foundation
import SwiftUI

class MockNetworkService: NetworkServiceProtocol {
        
        func fetchProducts() async throws -> [Product] {
                return []
        }
        
        func downloadImage(from urlString: String) async throws -> UIImage {
                
                return UIImage(systemName: "photo.fill")!
        }
}

// Des données "factices" mises à jour avec les VRAIES URLs
struct MockData {
        
        static let product = Product(
                id: 1,
                name: "Blazer Marron (Preview)",
                category: "TOPS",
                likes: 12,
                note: 20,
                price: 79.99,
                originalPrice: 89.99,
                picture: Picture(
                        
                        url: "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/img/tops/1.jpg",
                        description: "Ceci est une description pour l'accessibilité de la preview."
                )
        )
        
        static let products = [
                MockData.product,
                Product(
                        id: 2,
                        name: "Jean Stylé",
                        category: "BOTTOMS",
                        likes: 55,
                        note: 10,
                        price: 49.99,
                        originalPrice: 59.99,
                        picture: Picture(
                                
                                url: "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/img/bottoms/1.jpg",
                                description: "Un jean bleu."
                        )
                ),
                Product(
                        id: 3,
                        name: "Bottes Noires",
                        category: "SHOES",
                        likes: 20,
                        note: 7,
                        price: 99.99,
                        originalPrice: 119.99,
                        picture: Picture(
                                
                                url: "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/img/shoes/1.jpg",
                                description: "Des bottes de pluie."
                        )
                ),
                Product(
                        id: 4,
                        name: "Sac Blanc",
                        category: "SACS",
                        likes: 115,
                        note: 50,
                        price: 150.99,
                        originalPrice: 190.99,
                        picture: Picture(
                                
                                url: "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/img/shoes/1.jpg",
                                description: "Des bottes de pluie."
                        )
                )
        ]
}

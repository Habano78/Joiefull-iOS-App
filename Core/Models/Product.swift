//
//  Product.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation

struct Picture: Codable {
        let url: String
        let description: String
}

struct Product: Codable, Identifiable {
        let id: Int
        let name: String
        let category: String
        let likes: Int
        let price: Double
        let originalPrice: Double
        let picture: Picture
        
        enum CodingKeys: String, CodingKey {
                // lister tout ce qui correspond parfaitement
                case id, name, category, likes, price, picture
                // mapper ce qui est différent
                case originalPrice = "original_price"
        }
}

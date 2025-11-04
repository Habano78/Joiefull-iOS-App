//
//  Product.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation

struct Picture: Codable, Hashable {
        let url: String
        let description: String
}

struct Product: Codable, Identifiable, Hashable {
        let id: Int
        let name: String
        let category: String
        let likes: Int
        let price: Double
        let originalPrice: Double
        let picture: Picture
}

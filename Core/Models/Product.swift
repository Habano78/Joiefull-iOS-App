//
//  Product.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation

//MARK: mape le JSON de l'API
struct Product: Codable, Identifiable, Hashable {
        let id: Int
        let name: String
        let category: String
        let likes: Int
        let note: Double?
        let price: Double
        let originalPrice: Double
        let picture: ProductPicture
}

//
//  ProductSection.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//

import Foundation

struct ProductSection: Identifiable {
    
    let id = UUID()
    let category: String
    let products: [Product]
}

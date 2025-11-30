//
//  ProductSection.swift
//  Joiefull
//
//  Created by Perez William on 26/11/2025.
//

import Foundation

struct ProductSection: Identifiable, Equatable {
        let id: String
        let category: String
        let products: [Product]
        
        init(category: String, products: [Product]) {
                self.id = category
                self.category = category
                self.products = products
        }
}

//NOTE category comme id pour éviter la generation répétée de UUID et la reconstruction de la vue

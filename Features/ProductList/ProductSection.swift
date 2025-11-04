//
//  ProductSection.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//

import Foundation

import Foundation

// C'est un "Modèle de Vue" (View Model)
// Il ne sert qu'à structurer les données pour notre vue.
struct ProductSection: Identifiable {
    // 1. Un ID unique pour que la liste
    //    puisse boucler dessus.
    let id = UUID()
    
    // 2. Le titre (ex: "Hauts", "Bas")
    let category: String
    
    // 3. La liste des produits pour ce carrousel
    let products: [Product]
}

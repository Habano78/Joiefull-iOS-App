//
//  ProductDetailFavoriteStatus.swift
//  Joiefull
//
//  Created by Perez William on 18/11/2025.
//

import Foundation

struct ProductDetailFavoriteStatus: Equatable {
        
        var isFavorite: Bool
        var likesCount: Int
        
        mutating func toggle() {
                if isFavorite {
                        isFavorite = false
                        likesCount = max(0, likesCount - 1)
                } else {
                        isFavorite = true
                        likesCount += 1
                }
        }
}



//BUT : ProductDetailFavoriteStatus ne gère que les favoris; le reste du VM reste focalisé sur le produit, le partage, les avis, etc.

//BUT : Quand ProductDetailView se recompute à cause d’un autre changement d'état (ex : userRating, userComment, isPreparingShare…), SwiftUI voie que FavoriteState "c’est identique à avant, il ne re-diff pas l’intérieur de celui-ci”..

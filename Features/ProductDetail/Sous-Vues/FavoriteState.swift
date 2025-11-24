//
//  FavoriteState.swift
//  Joiefull
//
//  Created by Perez William on 18/11/2025.
//

import Foundation
import Combine

@MainActor
final class FavoriteState: ObservableObject, Equatable {
    
    @Published var isFavorite: Bool
    @Published var likesCount: Int
    
    init(isFavorite: Bool, likesCount: Int) {
        self.isFavorite = isFavorite
        self.likesCount = likesCount
    }
    
    func toggle() {
        isFavorite.toggle()
        likesCount += isFavorite ? 1 : -1
    }
    
    // Pour pouvoir comparer proprement deux FavoriteState si besoin
    static func == (lhs: FavoriteState, rhs: FavoriteState) -> Bool {
        lhs.isFavorite == rhs.isFavorite &&
        lhs.likesCount == rhs.likesCount
    }
}


//BUT : FavoriteState ne gère que les favoris; le reste du VM reste focalisé sur le produit, le partage, les avis, etc.

//BUT : Quand ProductDetailView se recompute à cause d’un autre changement d'état (ex : userRating, userComment, isPreparingShare…), SwiftUI voie que FavoriteState "c’est identique à avant, il ne re-diff pas l’intérieur de celui-ci”..

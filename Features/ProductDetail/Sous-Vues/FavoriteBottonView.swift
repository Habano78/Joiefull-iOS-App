//
//  FavoriteBottonView.swift
//  Joiefull
//
//  Created by Perez William on 24/11/2025.
//

import SwiftUI

struct FavoriteButtonView: View, Equatable {
        
        let isFavorite: Bool
        let likesCount: Int
        let onToggle: () -> Void
        
        static func == (lhs: FavoriteButtonView, rhs: FavoriteButtonView) -> Bool {
                lhs.isFavorite == rhs.isFavorite &&
                lhs.likesCount == rhs.likesCount
        }
        
        var body: some View {
                Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                onToggle()
                        }
                } label: {
                        HStack(spacing: 6) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(isFavorite ? .red : .black)
                                
                                Text("\(likesCount)")
                        }
                        .font(.subheadline.bold())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .accessibilityLabel(
                        Text(isFavorite
                             ? "Retirer des favoris"
                             : "Ajouter aux favoris")
                )
                .accessibilityValue(Text("\(likesCount) mentions j’aime"))
                .accessibilityHint(Text("Active ou désactive cet article en favori."))
        }
}

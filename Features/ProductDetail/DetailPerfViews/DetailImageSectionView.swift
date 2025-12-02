//
//  DetailImageSectionView.swift
//  Joiefull
//
//  Created by Perez William on 10/11/2025.
//

import SwiftUI

struct DetailImageSectionView : View, Equatable {
        
        // MARK: - Properties
        let imageUrl: String
        let isFavorite: Bool
        let likesCount: Int
        let onToggleFavorite: () -> Void
        
        //MARK: Equatable
        static func == (lhs: DetailImageSectionView, rhs: DetailImageSectionView) -> Bool {
                
                return lhs.imageUrl == rhs.imageUrl &&
                       lhs.isFavorite == rhs.isFavorite &&
                       lhs.likesCount == rhs.likesCount
            }
        
        // MARK: - Body
        var body: some View {
                
                let _ = print ("3. DetailImageSectionView se redessine")
                
                ZStack(alignment: .bottomTrailing) {
                        
                        // Image
                        RemoteImageView(
                                url: imageUrl,
                                contentMode: .fill
                        )
                        .frame(maxWidth: .infinity)
                        // Bouton favori
                        FavoriteButtonView(
                                isFavorite: isFavorite,
                                likesCount: likesCount,
                                onToggle: onToggleFavorite
                        )
                        .padding(12)
                }
                .clipped()
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
}

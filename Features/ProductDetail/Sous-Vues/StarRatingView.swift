//
//  StarRatingView.swift
//  Joiefull
//
//  Created by Perez William on 07/11/2025.
//

import SwiftUI

struct StarRatingView: View {
        
        @Binding var rating: Int
        var maxRating = 5
        var interactive = true
        
        var body: some View {
                HStack(spacing: 4) {
                        ForEach(1...maxRating, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.5))
                                        .onTapGesture {
                                                if interactive {
                                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                                rating = star
                                                        }
                                                }
                                        }
                        }
                }
                // Accessibilité Note
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Note de l’utilisateur"))
                .accessibilityValue(Text("\(rating) sur 5"))
                .accessibilityHint(
                        interactive
                        ? Text("Touchez pour modifier la note.")
                        : Text("Note en lecture seule.")
                )
        }
}

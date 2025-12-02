//
//  ProductRowView.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//

import SwiftUI

struct ProductRowView: View, Equatable {
        
        let product: Product
        let service: NetworkServiceProtocol
        
        // OPTIMISATION: on compare uniquement ce qui est AFFICHÉ dans cette carte pour limiter les reconstructions inutiles
        static func == (lhs: ProductRowView, rhs: ProductRowView) -> Bool {
                lhs.product.id == rhs.product.id &&
                lhs.product.name == rhs.product.name &&
                lhs.product.price == rhs.product.price &&
                lhs.product.originalPrice == rhs.product.originalPrice &&
                lhs.product.likes == rhs.product.likes &&
                lhs.product.note == rhs.product.note &&
                lhs.product.picture.url == rhs.product.picture.url
        }
        
        
        // MARK: - Body
        var body: some View {
                VStack(alignment: .leading, spacing: 4) {
                        
                        // Image + Badge FAVORIS
                        ZStack(alignment: .bottomTrailing) {
                                RemoteImageView(
                                        url: product.picture.url,
                                        contentMode: .fill
                                )
                                .frame(height: 180)
                                .clipped()
                                
                                // Badge Likes
                                HStack(spacing: 4) {
                                        Image(systemName: "heart")
                                                .fontWeight(.semibold)
                                        Text("\(product.likes)")
                                                .font(.caption.weight(.semibold))
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 4)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .padding(10)
                        }
                        .cornerRadius(16)
                        .padding(.bottom, 4)
                        
                        // Nom + Note
                        HStack(alignment: .top) {
                                Text(product.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                
                                Spacer()
                                
                                // Note
                                HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                        
                                        /// Pas de note dans l'API. On force l'affichage à 4.5
                                        Text(String(format: "%.1f", product.note ?? 4.5))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.black)
                                }
                        }
                        
                        // Prix + Prx Barré
                        HStack(alignment: .bottom) {
                                Text(String(format: "%.0f€", product.price))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                
                                Spacer()
                                
                                if product.originalPrice > product.price {
                                        Text(String(format: "%.0f€", product.originalPrice))
                                                .font(.system(size: 14))
                                                .strikethrough()
                                                .foregroundColor(.gray)
                                }
                        }
                }
                
                // Accessibilité
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(product.name), prix \(product.price) euros")
        }
}


// MARK: - Accessibility Helper

private extension ProductRowView {
        
        var accessibilityDescription: String {
                var components: [String] = []
                
                components.append(product.name)
                components.append("\(product.likes) favoris")
                
                if let note = product.note {
                        components.append("note \(String(format: "%.1f", note)) sur 5")
                }
                components.append("prix \(String(format: "%.2f", product.price)) euros")
                
                return components.joined(separator: ", ")
        }
}

//
//  ProductRowView.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//

//
//  ProductRowView.swift
//  Joiefull
//

import SwiftUI

struct ProductRowView: View, Equatable {
        
        let product: Product
        let service: NetworkServiceProtocol
        
        // ============================================================
        // OPTIMISATION: on compare uniquement ce qui est AFFICHÉ dans cette carte pour limiter les reconstructions inutiles
        // ============================================================
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
                
                VStack(alignment: .leading, spacing: 8) {
                        // IMAGE
                        ZStack(alignment: .bottomTrailing) {
                                
                                RemoteImageView(
                                        url: product.picture.url,
                                        service: service
                                )
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(10)
                                
                                // Badge "likes"
                                HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                        Text("\(product.likes)")
                                }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(8)
                        }
                        
                        // NOM
                        Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                                .frame(minHeight: 40, alignment: .top)
                        
                        // 💶 PRIX + ⭐️ NOTE
                        HStack(spacing: 8) {
                                
                                if let note = product.note {
                                        HStack(spacing: 2) {
                                                Image(systemName: "star.fill")
                                                Text(String(format: "%.1f", note))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(String(format: "%.2f €", product.price))
                                        .font(.subheadline.bold())
                                
                                if product.originalPrice > product.price {
                                        Text(String(format: "%.2f €", product.originalPrice))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .strikethrough()
                                }
                                
                                Spacer()
                        }
                }
                .padding(8)
                .background(Color.joiefullCardBackground)
                .cornerRadius(10)
                
                // ACCESSIBILITÉ
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityDescription)
                .accessibilityHint(product.picture.description)
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

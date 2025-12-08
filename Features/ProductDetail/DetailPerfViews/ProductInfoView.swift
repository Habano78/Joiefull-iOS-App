//
//  ProductInfoView.swift
//  Joiefull
//
//  Created by Perez William on 18/11/2025.
//

import Foundation
import SwiftUI

struct ProductInfoView: View, Equatable {
        
        let product: Product
        let accessibilityPriceDescription: String
        
        static func == (lhs: ProductInfoView, rhs: ProductInfoView) -> Bool {
                lhs.product == rhs.product &&
                lhs.accessibilityPriceDescription == rhs.accessibilityPriceDescription
        }
        
        var body: some View {
                
                VStack(alignment: .leading, spacing: 8) {
                        // Nom Produit + Note
                        HStack {
                                Text(product.name)
                                        .font(.title2.bold())
                                        .accessibilityAddTraits(.isHeader)
                               
                                Spacer()
                                
                                HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                                .foregroundColor(.joiefullStar)
                                        Text("4.6")
                                                .foregroundColor(.secondary)
                                }
                        }
                        
                        // Prix
                        HStack {
                                Text(String(format: "%.2f €", product.price))
                                        .font(.title3.weight(.semibold))
                                
                                Spacer()
                                
                                if product.originalPrice > product.price {
                                        Text(String(format: "%.2f €", product.originalPrice))
                                                .font(.subheadline)
                                                .strikethrough()
                                                .foregroundColor(.secondary)
                                }
                                
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(accessibilityPriceDescription))
                        
                        // Description
                        Text(product.picture.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                }
        }
}

// BUT de cette vue:
/// la vue prend un Product en valeur (pas via ViewModel)
/// on lui passe aussi la phrase d’accessibilité déjà calculée
/// Equatable compare product + accessibilityPriceDescription

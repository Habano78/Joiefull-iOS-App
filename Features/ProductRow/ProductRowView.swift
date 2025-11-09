//
//  ProductRowView.swift
//  Joiefull
//
//  Created by Perez William on 04/11/2025.
//
import SwiftUI

struct ProductRowView: View {
        
        let product: Product
        
        var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                        
                        ZStack(alignment: .bottomTrailing) {
                                
                                AsyncImage(url: URL(string: product.picture.url)) { phase in
                                        switch phase {
                                        case .empty:
                                                
                                                ProgressView()
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 150)
                                                        .background(Color.gray.opacity(0.1))
                                                
                                        case .success(let image):
                                                image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill) ///  .fill pour remplir le cadre comme sur la maquette/
                                                        .frame(height: 150)
                                                        .clipped()
                                                
                                        case .failure:
                                                Image(systemName: "photo.fill") ///Icone "pas d'image"
                                                        .foregroundColor(.gray)
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 150)
                                                        .background(Color.gray.opacity(0.1))
                                                
                                        @unknown default:
                                                EmptyView()
                                        }
                                }
                                .frame(height: 150)
                                
                                // Badge "Likes"
                                HStack(spacing: 4) {
                                        Image(systemName: "heart")
                                        Text("\(product.likes)")
                                }
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(8)
                                
                        }
                        .cornerRadius(10)
                        
                        
                        // Nom
                        Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                                .frame(minHeight: 40, alignment: .top)
                        
                        // Prix + Note
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                                
                                // LA NOTE (si elle existe car l'API ne la fournit pas)
                                if let note = product.note {
                                        HStack(spacing: 2) {
                                                Image(systemName: "star.fill")
                                                Text(String(format: "%.1f", note))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // PRIX : vente + barré
                                Text(String(format: "%.2f €", product.price))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                
                                if product.originalPrice > product.price { ///  Si le prix original est différent (en promo)
                                        Text(String(format: "%.2f €", product.originalPrice))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .strikethrough() /// modificateur "barré"
                                }
                                
                                Spacer()
                        }
                        
                        Spacer() // Pousse tout vers le haut
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                //MARK: ___ ACCESSIBILITÉ ___
                
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(product.name), \(product.likes) favoris, \(String(format: "%.2f", product.price)) euros")
                .accessibilityHint(product.picture.description)
        }
}


#Preview {
        ProductRowView(product: MockData.product)
                .padding()
                .frame(width: 200)
}

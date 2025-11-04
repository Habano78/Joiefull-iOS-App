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
                        
                        ZStack(alignment: .topTrailing) { /// ZStack pour superposer le badge des likes
                                
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
                                                        .clipped() ///coupe ce qui dépasse
                                                
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
                                
                                // Badge "Likes" (♡ 24)
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
                                
                        } // Fin du ZStack
                        .cornerRadius(10)
                        
        
                        // TEXTE
                        Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                        
                        Text(String(format: "%.2f €", product.price))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        
                        Spacer()
                }
                .padding(8)
                .background(Color.gray.opacity(0.1)) // Le fond de la carte
                .cornerRadius(10) // Les coins de la carte
                
                //MARK: --- ACCESSIBILITÉ ---
                
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(product.name), \(product.likes) favoris, \(String(format: "%.2f", product.price)) euros")
                .accessibilityHint(product.picture.description)
        }
}


#Preview {
        ProductRowView(product: MockData.product)
                .padding()
                .frame(width: 200) // Donne une largeur fixe pour l'aperçu
}

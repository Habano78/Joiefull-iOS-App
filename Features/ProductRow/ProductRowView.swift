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
                // empiler l'image et le texte
                VStack(alignment: .leading, spacing: 8) {
                        
                        AsyncImage(url: URL(string: product.picture.url)) { phase in
                                switch phase {
                                case .empty:
                                        // Pendant le chargement
                                        ProgressView()
                                case .success(let image):
                                        // Si l'image est chargée
                                        image
                                                .resizable() // La rend redimensionnable
                                                .aspectRatio(contentMode: .fit) // Garde les proportions
                                                .cornerRadius(10)
                                case .failure:
                                        // En cas d'erreur réseau
                                        Image(systemName: "photo.fill")
                                                .foregroundColor(.gray)
                                @unknown default:
                                        EmptyView()
                                }
                        }
                        .frame(height: 150)
                        
                        // LE TEXTE
                        Text(product.name)
                                .font(.headline)
                                .lineLimit(2)
                        
                        Text(String(format: "%.2f €", product.price))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        
                        Spacer()
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                //MARK:  --- ACCESSIBILITÉ ---
                
                // Combine tous les éléments en un seul "bouton"
                // pour VoiceOver
                .accessibilityElement(children: .combine)
                // L'étiquette lue par VoiceOver
                .accessibilityLabel("\(product.name), \(String(format: "%.2f", product.price)) euros")
                // L'indice (l'alt-text de l'API !)
                .accessibilityHint(product.picture.description)
        }
}

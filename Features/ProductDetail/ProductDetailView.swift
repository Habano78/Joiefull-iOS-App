//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
import SwiftUI

struct ProductDetailView: View {
        
        // 1. La source de vérité pour cet écran
        @StateObject private var viewModel: ProductDetailViewModel
        
        // 2. L'init qui permet l'injection
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                // Pour l'instant, on affiche juste l'image et la description
                ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                                
                                // L'image (comme dans le RowView)
                                AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in
                                        if let image = phase.image {
                                                image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                        } else if phase.error != nil {
                                                Image(systemName: "photo.fill") // Erreur
                                        } else {
                                                ProgressView() // Chargement
                                        }
                                }
                                
                                Text(viewModel.product.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                
                                Text(viewModel.product.picture.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                
                                Text(String(format: "%.2f €", viewModel.product.price))
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                
                                Spacer()
                        }
                        .padding()
                }
                // Le titre de la barre de navigation
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
        }
}

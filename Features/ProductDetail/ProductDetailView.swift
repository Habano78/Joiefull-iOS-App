//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
//

import SwiftUI

struct ProductDetailView: View {
        
        // MARK: - Properties
        
        @StateObject private var viewModel: ProductDetailViewModel
        
        // MARK: - Init
        
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        // MARK: - Body
        
        var body: some View {
                ZStack {
                        
                        ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                        
                                        //  IMAGE + BADGES
                                        ZStack(alignment: .bottomTrailing) {
                                                
                                                /// Image prioritaire  (cache local)
                                                if let uiImage = viewModel.imageToShare {
                                                        Image(uiImage: uiImage)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(height: 400)
                                                                .clipped()
                                                }
                                                else {
                                                        AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in
                                                                switch phase {
                                                                case .empty:
                                                                        Color.gray.opacity(0.1)
                                                                                .frame(height: 400)
                                                                case .success(let image):
                                                                        image.resizable()
                                                                                .aspectRatio(contentMode: .fill)
                                                                                .frame(height: 400)
                                                                                .clipped()
                                                                case .failure(_):
                                                                        Color.gray.opacity(0.1)
                                                                                .frame(height: 400)
                                                                @unknown default:
                                                                        Color.gray.opacity(0.1)
                                                                                .frame(height: 400)
                                                                }
                                                        }
                                                }
                                                
                                                // Bouton Favoris
                                                Button {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                                viewModel.toggleFavorite()
                                                        }
                                                } label: {
                                                        HStack(spacing: 4) {
                                                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                                                        .foregroundColor(viewModel.isFavorite ? .red : .black)
                                                                
                                                                Text("\(viewModel.likesCounting)")
                                                        }
                                                        .font(.subheadline.weight(.bold))
                                                        .foregroundColor(.black)
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 12)
                                                        .background(Color.white)
                                                        .cornerRadius(12)
                                                }
                                                .padding(12)
                                        }
                                        .cornerRadius(24)
                                        .padding(.horizontal)
                                        
                                        
                                        // INFORMATIONS PRODUIT
                                        VStack(alignment: .leading, spacing: 8) {
                                                
                                                Text(viewModel.product.name)
                                                        .font(.title2.weight(.bold))
                                                
                                                HStack {
                                                        Text(String(format: "%.2f €", viewModel.product.price))
                                                                .font(.title3.weight(.semibold))
                                                        
                                                        Spacer()
                                                        
                                                        HStack {
                                                                Image(systemName: "star.fill")
                                                                        .foregroundColor(.joiefullStar)
                                                                Text("4.6")
                                                                        .foregroundColor(.secondary)
                                                        }
                                                        
                                                        if viewModel.product.originalPrice > viewModel.product.price {
                                                                Text(String(format: "%.2f €", viewModel.product.originalPrice))
                                                                        .strikethrough()
                                                                        .foregroundColor(.secondary)
                                                        }
                                                }
                                                
                                                Text(viewModel.product.picture.description)
                                                        .foregroundColor(.secondary)
                                                        .padding(.top, 8)
                                                
                                        }
                                        .padding(.horizontal)
                                        
                                        Divider().padding(.horizontal)
                                        
                                        
                                        // AVIS UTILISATEUR
                                        
                                        VStack(alignment: .leading, spacing: 12) {
                                                Text("Avis").font(.headline)
                                                
                                                HStack {
                                                        StarRatingView(rating: $viewModel.userRating)
                                                        Spacer()
                                                        Text("\(viewModel.userRating)/5")
                                                                .foregroundColor(.secondary)
                                                }
                                                
                                                TextEditor(text: $viewModel.userComment)
                                                        .frame(height: 100)
                                                        .padding(4)
                                                        .background(Color.joiefullCardBackground)
                                                        .cornerRadius(8)
                                                
                                                Button {
                                                        withAnimation {
                                                                viewModel.userRating = 0
                                                                viewModel.userComment = ""
                                                        }
                                                } label: {
                                                        Text("Envoyer mon avis")
                                                                .fontWeight(.semibold)
                                                                .frame(maxWidth: .infinity)
                                                                .padding()
                                                                .background(Color.joiefullPrimary)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(12)
                                                }
                                                .disabled(viewModel.userRating == 0)
                                                .opacity(viewModel.userRating == 0 ? 0.6 : 1)
                                                
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 40)
                                        
                                }
                                .padding(.top)
                        }
                        
                        
                        // SPINNER
                        if viewModel.isPreparingShare {
                                Color.joiefullSpinnerOverlay
                                        .edgesIgnoringSafeArea(.all)
                                
                                ProgressView("Préparation…")
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(10)
                        }
                }
                
                
                // MARK: Toolbar + Navigation
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        Task {
                                                await viewModel.handleShareButtonTapped()
                                        }
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                        }
                }
                
                // Préchargement automatique
                .task {
                        await viewModel.preloadShareableImage()
                }
                
                // Feuille de partage
                .sheet(isPresented: $viewModel.isShowingShareSheet, onDismiss: {
                        viewModel.resetShareableImage()
                }) {
                        if let image = viewModel.imageToShare {
                                let message = "Regarde cet article sur Joiefull : \(viewModel.product.name)"
                                let provider = ImageShareProvider(image: image, message: message)
                                ShareSheet(items: [provider, message])
                        }
                }
        }
}


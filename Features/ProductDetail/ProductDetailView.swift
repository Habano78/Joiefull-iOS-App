//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
//

import SwiftUI

struct ProductDetailView: View {
        
        //MARK: --- Properties ---
        
        @StateObject private var viewModel: ProductDetailViewModel
        
        
        //MARK:  Init
        
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        
        //MARK:  Body
        
        var body: some View {
                ZStack {
                        
                        ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                        
                                        //MARK: IMAGE + BADGES
                                        ZStack(alignment: .bottomTrailing) {
                                                
                                                if let uiImage = viewModel.imageToShare {
                                                        Image(uiImage: uiImage)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(height: 400)
                                                                .clipped()
                                                } else {
                                                        AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in ///Fallback
                                                                switch phase {
                                                                case .empty:
                                                                        Color.gray.opacity(0.1)
                                                                                .frame(height: 400)
                                                                        
                                                                case .success(let image):
                                                                        image
                                                                                .resizable()
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
                                                
                                                //MARK: Bouton Favoris
                                                Button {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                                viewModel.toggleFavorite()
                                                        }
                                                } label: {
                                                        HStack(spacing: 4) {
                                                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")/// Cœur plein/vide selon l'état
                                                                        .foregroundColor(viewModel.isFavorite ? .red : .black)
                                                                
<<<<<<< HEAD
                                                                // Nombre de likes
                                                                Text("\(viewModel.likesCount)")
=======
                                                                Text("\(viewModel.product.likes)")
>>>>>>> dev
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
                                        
                                        
                                        //MARK: Nom + Prix + Note + Description
                                        VStack(alignment: .leading, spacing: 8) {
                                                
                                                Text(viewModel.product.name)
                                                        .font(.title2.weight(.bold))
                                                
                                                HStack {
                                                        // Prix de vente
                                                        Text(String(format: "%.2f €", viewModel.product.price))
                                                                .font(.title3.weight(.semibold))
                                                                .foregroundColor(.primary)
                                                        
                                                        Spacer()
                                                        
                                                        // Note (statique pour la démo, car absente de l'API)
                                                        HStack(spacing: 4) {
                                                                Image(systemName: "star.fill")
                                                                        .foregroundColor(.joiefullStar)
                                                                Text("4.6")
                                                                        .font(.subheadline.weight(.semibold))
                                                                        .foregroundColor(.secondary)
                                                        }
                                                        
                                                        // Prix barré (si promo)
                                                        if viewModel.product.originalPrice > viewModel.product.price {
                                                                Text(String(format: "%.2f €", viewModel.product.originalPrice))
                                                                        .font(.subheadline)
                                                                        .strikethrough()
                                                                        .foregroundColor(.secondary)
                                                                        .padding(.leading, 4)
                                                        }
                                                }
                                                .frame(maxWidth: .infinity)
                                                
                                                // Description (alt-text)
                                                Text(viewModel.product.picture.description)
                                                        .font(.body)
                                                        .foregroundColor(.secondary)
                                                        .padding(.top, 8)
                                                
                                        }
                                        .padding(.horizontal)
                                        
                                        Divider().padding(.horizontal)
                                        
                                        
                                        //MARK: AVIS
                                        VStack(alignment: .leading, spacing: 12) {
                                                Text("Avis").font(.headline)
                                                
                                                // Étoiles interactives
                                                HStack {
                                                        StarRatingView(rating: $viewModel.userRating)
                                                        Spacer()
                                                        Text("\(viewModel.userRating)/5")
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                }
                                                
                                                // Champ texte
                                                TextEditor(text: $viewModel.userComment)
                                                        .frame(height: 100)
                                                        .padding(4)
                                                        .background(Color.joiefullCardBackground) // Constante de couleur
                                                        .cornerRadius(8)
                                                
                                                // Bouton d'envoi
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
                        } // Fin ScrollView
                        
                        
                        //MARK: SPINNER (Overlay)
                        if viewModel.isPreparingShare {
                                Color.joiefullSpinnerOverlay // Constante de couleur
                                        .edgesIgnoringSafeArea(.all)
                                
                                ProgressView("Préparation...")
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(10)
                        }
                        
                } 
                
                //MARK: Gestionnaires
                
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                
                // Bouton Partager dans la barre
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

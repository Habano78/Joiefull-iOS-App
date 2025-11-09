//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
//

import SwiftUI

struct ProductDetailView: View {
        
        @StateObject private var viewModel: ProductDetailViewModel
        @State private var triggerTask = false
        
        //MARK: Init
        
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                
                ZStack {
                        
                        ScrollView {
                                
                                VStack(alignment: .leading, spacing: 20) {
                                        
                                        //MARK: BLOC IMAGE + BADGES
                                        ZStack(alignment: .bottomTrailing) {
                                                
                                                AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in
                                                        if let image = phase.image {
                                                                image.resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                                        .frame(height: 400)
                                                                        .clipped()
                                                        } else if phase.error != nil {
                                                                Image(systemName: "photo.fill")
                                                                        .frame(height: 400)
                                                                        .foregroundColor(.gray.opacity(0.3))
                                                        } else {
                                                                ProgressView()
                                                                        .frame(height: 400)
                                                                        .frame(maxWidth: .infinity)
                                                                        .background(Color.gray.opacity(0.1))
                                                        }
                                                }
                                                
                                                
                                                // ___ Coeur Interactif___
                                                Button {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                                viewModel.toggleFavorite()
                                                        }
                                                } label: {
                                                        HStack(spacing: 4) {
                                                                
                                                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart") ///// L'icône change selon l'état !
                                                                        .foregroundColor(viewModel.isFavorite ? .red : .black)
                                                                
                                                                Text("\(viewModel.product.likes + (viewModel.isFavorite ? 1 : 0))")
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
                                        
                                        
                                        //MARK: ___ Bloc Informations ___
                                        VStack(alignment: .leading, spacing: 8) {
                                                
                                                HStack  {
                                                        // nom de Produit
                                                        Text(viewModel.product.name)
                                                                .font(.title2.weight(.bold))
                                                        
                                                        Spacer()
                                                        // NOTE FAKE ici car la note n'est pas donnée par l'API
                                                        HStack(spacing: 4) {
                                                                Image(systemName: "star.fill")
                                                                        .foregroundColor(.yellow)
                                                                Text("4.6")
                                                                        .font(.subheadline.weight(.semibold))
                                                                        .foregroundColor(.secondary)
                                                        }
                                                }
                                                
                                                HStack {
                                                        // Prix de vente
                                                        Text(String(format: "%.2f €", viewModel.product.price))
                                                                .font(.title3.weight(.semibold))
                                                                .foregroundColor(.primary)
                                                        
                                                        Spacer()
                                                        // Prix barré (si promo)
                                                        if viewModel.product.originalPrice > viewModel.product.price {
                                                                Text(String(format: "%.2f €", viewModel.product.originalPrice))
                                                                        .font(.subheadline)
                                                                        .strikethrough()
                                                                        .foregroundColor(.secondary)
                                                        }
                                                        
                                                        
                                                }
                                                
                                                // Description
                                                Text(viewModel.product.picture.description)
                                                        .font(.body)
                                                        .foregroundColor(.secondary)
                                                        .padding(.top, 8)
                                                
                                        }
                                        .padding(.horizontal)
                                        
                                        Divider().padding(.horizontal)
                                        
                                        
                                        //MARK: ___ Section Avis ___
                                        VStack(alignment: .leading, spacing: 12) {
                                                Text("Avis").font(.headline)
                                                
                                                // Note interactive
                                                HStack {
                                                        StarRatingView(rating: $viewModel.userRating)
                                                        Spacer()
                                                        Text("\(viewModel.userRating)/5")
                                                                .font(.subheadline)
                                                                .foregroundColor(.secondary)
                                                }
                                                
                                                // Champ de commentaire
                                                TextEditor(text: $viewModel.userComment)
                                                        .frame(height: 100)
                                                        .padding(4)
                                                        .background(Color.gray.opacity(0.1))
                                                        .cornerRadius(8)
                                                
                                                // Bouton d'envoi (fake))
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
                                                                .background(Color.blue)
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
                        
                        //MARK: ___ SPINNER ___
                        if viewModel.isPreparingShare {
                                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                                ProgressView("Préparation...")
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                        }
                        
                }
                
                //MARK: ___ Configuration Navigation ___
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        // Bouton Partager
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        self.triggerTask = true
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                        }
                }
                
                //MARK: ___ Task & Sheet ___
                
                // Tâche de préparation du partage
                .task(id: triggerTask) {
                        guard triggerTask else { return }
                        await viewModel.prepareShareableImage()
                        self.triggerTask = false
                }
                
                // Feuille de partage
                .sheet(isPresented: $viewModel.isShowingShareSheet, onDismiss: {
                        viewModel.resetShareableImage()
                }) {
                        if let image = viewModel.imageToShare {
                                let message = "Regarde cet article sur Joiefull : \(viewModel.product.name)"
                                
                                // utilisation du WRAPPER
                                let shareProvider = ImageShareProvider(image: image, message: message)
                                ShareSheet(items: [shareProvider])
                        }
                }
        }
}

//MARK: ___ Preview ___
#Preview {
        let mockProduct = MockData.product
        let mockService = MockNetworkService()
        let viewModel = ProductDetailViewModel(product: mockProduct, service: mockService)
        
        return NavigationStack {
                ProductDetailView(viewModel: viewModel)
                        .navigationTitle("Home")
        }
}

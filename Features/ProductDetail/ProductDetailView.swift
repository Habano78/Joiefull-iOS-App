//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
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
                                        
                                        // MARK: IMAGE + FAVORIS
                                        // MARK: IMAGE + FAVORIS
                                        ZStack(alignment: .bottomTrailing) {

                                            RemoteImageView(
                                                url: viewModel.product.picture.url,
                                                service: viewModel.service,
                                                contentMode: .fit              // on veut voir la photo ENTIEREMENT
                                            )
                                           // .aspectRatio(4.0 / 3.0, contentMode: .fill)
                                            .frame(maxWidth: .infinity)        // prend toute la largeur dispo
                                            .clipped()
                                            .accessibilityElement(children: .ignore)
                                            .accessibilityLabel(Text(viewModel.product.picture.description))
                                            .accessibilityAddTraits(.isImage)

                                            FavoriteButtonView(
                                                isFavorite: viewModel.favoriteState.isFavorite,
                                                likesCount: viewModel.favoriteState.likesCount,
                                                onToggle: { viewModel.favoriteState.toggle() }
                                            )
                                            .equatable()
                                            .padding(12)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                        .padding(.horizontal)

                                        
                                        
                                        
                                        // MARK: INFORMATIONS PRODUIT (SubView)
                                        
                                        ProductInfoView(
                                                product: viewModel.product,
                                                accessibilityPriceDescription: a11yPriceDescription
                                        )
                                        .equatable()
                                        
                                        
                                        
                                        Divider().padding(.horizontal)
                                        
                                        
                                        // MARK: - 3. SECTION AVIS
                                        VStack(alignment: .leading, spacing: 12) {
                                                
                                                Text("Avis")
                                                        .font(.headline)
                                                        .accessibilityAddTraits(.isHeader)
                                                
                                                // RATING
                                                HStack {
                                                        StarRatingView(rating: $viewModel.userRating)
                                                        Spacer()
                                                        Text("\(viewModel.userRating)/5")
                                                                .foregroundColor(.secondary)
                                                }
                                                
                                                // COMMENT
                                                TextEditor(text: $viewModel.userComment)
                                                        .frame(height: 100)
                                                        .padding(4)
                                                        .background(Color.joiefullCardBackground)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                                                        )
                                                        .foregroundColor(.primary)
                                                        .accessibilityLabel("Commentaire")
                                                        .accessibilityHint("Entrez votre avis sur cet article.")
                                                
                                                
                                                // SEND BUTTON
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
                                                .accessibilityLabel("Envoyer mon avis")
                                                .accessibilityHint("Envoie votre avis pour cet article")
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 40)
                                        
                                }
                                .padding(.top)
                        }
                        .accessibilityHidden(viewModel.isPreparingShare)
                        
                        
                        // MARK: - LOADING OVERLAY
                        if viewModel.isPreparingShare {
                                Color.joiefullSpinnerOverlay
                                        .edgesIgnoringSafeArea(.all)
                                
                                ProgressView("Préparation…")
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(10)
                                        .accessibilityElement(children: .combine)
                                
                        }
                        
                        
                }
                // MARK: - Navigation
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                
                // MARK: - Toolbar (Share)
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        Task { await viewModel.handleShareButtonTapped() }
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                                .accessibilityLabel("Partager cet article")
                                .accessibilityHint("Ouvre la feuille de partage")
                        }
                }
                
                // MARK: - Preload image on appear
                .task {
                        if viewModel.imageToShare == nil { await viewModel.preloadShareableImage() }
                }
                
                
                // MARK: - Share Sheet
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

// MARK: - Helpers Accessibility

private extension ProductDetailView {
        var a11yPriceDescription: String {
                let current = String(format: "%.2f euros", viewModel.product.price)
                
                if viewModel.product.originalPrice > viewModel.product.price {
                        let original = String(format: "%.2f euros", viewModel.product.originalPrice)
                        return "Prix actuel : \(current). Ancien prix : \(original). Note 4,6 sur 5."
                } else {
                        return "Prix : \(current). Note 4,6 sur 5."
                }
        }
}



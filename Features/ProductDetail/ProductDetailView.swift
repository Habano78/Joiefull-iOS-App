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
                                        
                                        // Image + Favoris
                                        ZStack(alignment: .bottomTrailing) {
                                                
                                                RemoteImageView(
                                                        url: viewModel.product.picture.url,
                                                        service: viewModel.service,
                                                        contentMode: .fill              
                                                )
                                                .frame(height: 390)
                                                .clipped()
                                                .accessibilityElement(children: .ignore)
                                                .accessibilityLabel(Text(viewModel.product.picture.description))
                                                .accessibilityAddTraits(.isImage)
                                                
                                                FavoriteButtonView(
                                                        isFavorite: viewModel.favoriteStatus.isFavorite,
                                                        likesCount: viewModel.favoriteStatus.likesCount,
                                                        onToggle: { viewModel.favoriteStatus.toggle() }
                                                )
                                                .equatable()
                                                .padding(12)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                        .padding(.horizontal)
                                        
                                        
                                        // Infos du Produit
                                        ProductInfoView(
                                                product: viewModel.product,
                                                accessibilityPriceDescription: a11yPriceDescription
                                        )
                                        .equatable()
                                        
                                        Divider().padding(.horizontal)
                                        
                                        
                                        // Section Avis
                                        VStack(alignment: .leading, spacing: 12) {
                                                
                                                Text(NSLocalizedString("SECTION_REVIEWS_TITLE", comment: "")) // ⬅️ LOCALISÉ : "Avis"
                                                        .font(.headline)
                                                        .accessibilityAddTraits(.isHeader)
                                                
                                                // Note
                                                HStack {
                                                        StarRatingView(rating: $viewModel.userRating)
                                                        Spacer()
                                                        Text("\(viewModel.userRating)/5")
                                                                .foregroundColor(.secondary)
                                                }
                                                
                                                // Avis
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
                                                        .accessibilityLabel(NSLocalizedString("COMMENT_FIELD_LABEL", comment: ""))
                                                        .accessibilityHint(NSLocalizedString("COMMENT_FIELD_HINT", comment: "")) //
                                                
                                                // Bouton Avis
                                                Button {
                                                        withAnimation {
                                                                viewModel.userRating = 0
                                                                viewModel.userComment = ""
                                                        }
                                                } label: {
                                                        Text(NSLocalizedString("SUBMIT_REVIEW_BUTTON", comment: ""))
                                                                .fontWeight(.semibold)
                                                                .frame(maxWidth: .infinity)
                                                                .padding()
                                                                .background(Color.joiefullPrimary)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(12)
                                                }
                                                .disabled(viewModel.userRating == 0)
                                                .opacity(viewModel.userRating == 0 ? 0.6 : 1)
                                                .accessibilityLabel(NSLocalizedString("SUBMIT_REVIEW_BUTTON", comment: ""))
                                                .accessibilityHint(NSLocalizedString("SUBMIT_REVIEW_HINT", comment: ""))
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 40)
                                        
                                }
                                .padding(.top)
                        }
                        .accessibilityHidden(viewModel.isLoadingImage)
                        
                        
                        // MARK: LOADING OVERLAY
                        if viewModel.isLoadingImage {
                                Color.joiefullSpinnerOverlay
                                        .edgesIgnoringSafeArea(.all)
                                
                                ProgressView(NSLocalizedString("SHARE_LOADING_MESSAGE", comment: ""))
                                        .padding()
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(10)
                                        .accessibilityElement(children: .combine)
                                
                        }
                        
                }
                // MARK:  Navigation
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                
                // MARK: Toolbar (Partage)
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        Task { await viewModel.handleShareButtonTapped() }
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                                .accessibilityLabel(NSLocalizedString("SHARE_BUTTON_LABEL", comment: ""))
                                .accessibilityHint(NSLocalizedString("SHARE_BUTTON_HINT", comment: ""))
                        }
                }
                
                
                // MARK: Share Sheet
                .sheet(isPresented: $viewModel.isShowingShareSheet, onDismiss: {
                        viewModel.resetShareableImage()
                }) {
                        if let image = viewModel.imageReadyToShare {
                                let format = NSLocalizedString("SHARE_MESSAGE_FORMAT", comment: "")
                                let message = String(format: format, viewModel.product.name)
                                let provider = ImageShareProvider(image: image, message: message)
                                ShareSheet(items: [provider, message])
                        }
                }
                .alert(
                        NSLocalizedString("SHARE_ERROR_TITLE", comment: "Titre de l'alerte d'erreur de partage"),
                        isPresented: .constant(viewModel.shareError != nil),
                        presenting: viewModel.shareError
                ) { error in
                        Button("OK") {
                                viewModel.shareError = nil
                        }
                } message: { error in
                        Text(NSLocalizedString("SHARE_ERROR_MESSAGE", comment: "Message de l'alerte d'erreur de partage"))
                }
        }
        
        //MARK: Prix Accésibilité
        var a11yPriceDescription: String {
                AccessibilityPriceHelper.generateA11yPriceDescription(
                        currentPrice: viewModel.product.price,
                        originalPrice: viewModel.product.originalPrice
                )
        }
}

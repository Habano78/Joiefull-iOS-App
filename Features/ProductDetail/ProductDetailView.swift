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
                
                ///let _ = print("1. Vue Parent ProductDetailView se recalcule)
                
                ZStack {
                        
                        Color(uiColor: .systemGroupedBackground)
                                .ignoresSafeArea()
                        
                        ScrollView {
                                // Contenu de la carte
                                VStack(alignment: .leading, spacing: 0) {
                                        ViewThatFits(in: .horizontal) {
                                                
                                                // VERSION IPAD
                                                HStack(alignment: .top, spacing: 30) {
                                                        
                                                        DetailImageSectionView(
                                                                imageUrl: viewModel.product.picture.url,
                                                                isFavorite: viewModel.favoriteStatus.isFavorite,
                                                                likesCount: viewModel.favoriteStatus.likesCount,
                                                                onToggleFavorite: { viewModel.favoriteStatus.toggle() }
                                                        )
                                                        .equatable()
                                                        .frame(height: 500)
                                                        .layoutPriority(1)
                                                        
                                                        VStack(alignment: .leading, spacing: 20) {
                                                                DetailContentView(
                                                                        product: viewModel.product,
                                                                        accessibilityPriceDescription: a11yPriceDescription,
                                                                        userRating: $viewModel.userRating,
                                                                        userComment: $viewModel.userComment,
                                                                        onSubmitReview: {
                                                                                withAnimation {
                                                                                        viewModel.userRating = 0
                                                                                        viewModel.userComment = "" /// Réinitialisation après envoi
                                                                                }
                                                                        }
                                                                )
                                                                .equatable()
                                                        }
                                                }
                                                
                                                // VERSION IPHONE
                                                VStack(spacing: 0) {
                                                        DetailImageSectionView(
                                                                imageUrl: viewModel.product.picture.url,
                                                                isFavorite: viewModel.favoriteStatus.isFavorite,
                                                                likesCount: viewModel.favoriteStatus.likesCount,
                                                                onToggleFavorite: { viewModel.favoriteStatus.toggle() }
                                                        )
                                                        .equatable()
                                                        .aspectRatio(0.9, contentMode: .fit)
                                                        .frame(maxWidth: .infinity)
                                                        
                                                        VStack(alignment: .leading, spacing: 20) {
                                                                
                                                                DetailContentView(
                                                                        product: viewModel.product,
                                                                        accessibilityPriceDescription: a11yPriceDescription,
                                                                        userRating: $viewModel.userRating,
                                                                        userComment: $viewModel.userComment,
                                                                        onSubmitReview: {
                                                                                withAnimation {
                                                                                        viewModel.userRating = 0
                                                                                        viewModel.userComment = ""
                                                                                }
                                                                        }
                                                                )
                                                                .equatable()
                                                        }
                                                        .padding(.top, 20)
                                                }
                                        }
                                }
                                .padding(24)
                                .background(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .fill(Color(uiColor: .systemBackground))
                                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                        }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        Task { await viewModel.ShareButtonTapped();
                                                print("Bouton appuyé") }
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                        }
                }
                ///Feuille de partage branchée sur le ViewModel
                .sheet(item: $viewModel.activeShareItem) { item in
                        let provider = ImageShareProvider(image: item.image, message: item.message)
                        ShareSheet(items: [provider, item.message])
                }
                .alert("Erreur", isPresented: $viewModel.isShowingErrorAlert) {
                        Button("OK", role: .cancel) { }
                } message: {
                        Text(viewModel.shareError?.localizedDescription ?? "Impossible de télécharger l'image.")
                }
                
                // Prix Accésibilité
                var a11yPriceDescription: String {
                        AccessibilityPriceHelper.generateA11yPriceDescription(
                                currentPrice: viewModel.product.price,
                                originalPrice: viewModel.product.originalPrice
                        )
                }
        }
}

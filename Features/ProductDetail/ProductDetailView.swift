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
                                                        .frame(height: 500) 
                                                        .layoutPriority(1)
                                                        
                                                        VStack(alignment: .leading, spacing: 20) {
                                                                detailsSection
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
                                                        .aspectRatio(0.9, contentMode: .fit)
                                                        .frame(maxWidth: .infinity)
                                                        
                                                        VStack(alignment: .leading, spacing: 20) {
                                                                detailsSection
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
                .navigationTitle(viewModel.product.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                        Task { await viewModel.handleShareButtonTapped() }
                                } label: {
                                        Image(systemName: "square.and.arrow.up")
                                }
                        }
                }
        }
        
        
        // MARK: - Subview pour alléger le code
        
        
        // Info, Description, Avis
        private var detailsSection: some View {
                VStack(alignment: .leading, spacing: 20) {
                        
                        ProductInfoView(
                                product: viewModel.product,
                                accessibilityPriceDescription: a11yPriceDescription
                        )
                        
                        Divider()
                        
                        // Section Avis
                        VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("SECTION_REVIEWS_TITLE", comment: ""))
                                        .font(.headline)
                                
                                HStack {
                                        StarRatingView(rating: $viewModel.userRating)
                                        Spacer()
                                        Text("\(viewModel.userRating)/5").foregroundColor(.secondary)
                                }
                                
                                TextEditor(text: $viewModel.userComment)
                                        .frame(height: 100)
                                        .padding(4)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                                
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
                        }
                }
                .padding(.bottom, 40)
        }
        
        // Prix Accésibilité
        var a11yPriceDescription: String {
                AccessibilityPriceHelper.generateA11yPriceDescription(
                        currentPrice: viewModel.product.price,
                        originalPrice: viewModel.product.originalPrice
                )
        }
}

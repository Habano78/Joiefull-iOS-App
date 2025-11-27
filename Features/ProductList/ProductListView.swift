//
//  ProductListView..swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import SwiftUI

struct ProductListView: View {
        
        // MARK: - Propriétés
        
        @EnvironmentObject private var diContainer: AppDIContainer
        @StateObject private var viewModel: ProductListViewModel
        
        // États pour iPad
        @State private var selectedProduct: Product?
        @State private var columnVisibility = NavigationSplitViewVisibility.all
        
        
        // MARK: - Init
        
        init(viewModel: ProductListViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        
        // MARK: - Body
        
        var body: some View {
                
                NavigationSplitView(columnVisibility: $columnVisibility) {
                        
                        // COLONNE GAUCHE
                        
                        Group {
                                switch viewModel.state {
                                        
                                case .idle:
                                        Color.clear
                                        
                                case .loading:
                                        ProgressView(NSLocalizedString("SHARE_LOADING_MESSAGE", comment: ""))
                                        
                                case .error(let message):
                                        VStack(spacing: 20) {
                                                Text("ERROR_MESSAGE_FORMAT \(message)")
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.center)
                                                
                                                Button("RETRY_BUTTON_LABEL"){
                                                        Task { await viewModel.reload() }
                                                }
                                                .buttonStyle(.borderedProminent)
                                        }
                                        .padding()
                                        
                                case .loaded(let sections):
                                        List(selection: $selectedProduct) {
                                                ForEach(sections) { section in
                                                        ProductSectionView(
                                                                section: section,
                                                                service: diContainer.networkService,
                                                                onProductSelected: { product in
                                                                        selectedProduct = product
                                                                }
                                                        )
                                                }
                                        }
                                        .listStyle(.plain)
                                }
                        }
                        .navigationTitle("PRODUCT_LIST_TITLE")
                        .navigationSplitViewColumnWidth(min: 320, ideal: 450, max: 500)
                        
                } detail: {
                        
                        // COLONNE DROITE
                        
                        if let product = selectedProduct {
                                ProductDetailView(viewModel: diContainer.makeProductDetailViewModel(product: product))
                                        .environmentObject(diContainer)
                                        .id(product.id)
                        } else {
                                VStack(spacing: 20) {
                                        Image(systemName: "tshirt")
                                                .font(.system(size: 80))
                                                .foregroundColor(.gray.opacity(0.3))
                                        
                                        Text("DETAIL_VIEW_PLACEHOLDER") /// "Sélectionnez un article\npour voir les détails"
                                                .font(.title2)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.secondary)
                                }
                        }
                }
                
                .task {
                        if case .idle = viewModel.state {
                                await viewModel.reload()
                        }
                }
        }
}

//
//  ProductListView..swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import SwiftUI

struct ProductListView: View {
        
        //MARK: Proprietés
        
        @EnvironmentObject private var diContainer: AppDIContainer
        @StateObject private var viewModel: ProductListViewModel
        
        // États pour la navigation iPad
        @State private var selectedProduct: Product?
        @State private var columnVisibility = NavigationSplitViewVisibility.all
        
        
        //MARK: Init
        init(viewModel: ProductListViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        //MARK: Body
        var body: some View {
                // Gestion de l'iPad avec NavigationSplitView
                NavigationSplitView(columnVisibility: $columnVisibility) {
                        //  COLONNE DE GAUCHE
                        Group {
                                switch viewModel.state {
                                case .idle:
                                        Color.clear
                                        
                                case .loading:
                                        ProgressView("Chargement...")
                                        
                                case .error(let message):
                                        VStack(spacing: 20) {
                                                Text("Erreur: \(message)")
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.center)
                                                Button("Réessayer") {
                                                        Task { await viewModel.reload() }
                                                }
                                                .buttonStyle(.borderedProminent)
                                        }
                                        .padding()
                                        
                                case .loaded(let sections):
                                        loadedProductList(sections: sections)
                                }
                        }
                        .navigationTitle("Catalogue")
                        .navigationSplitViewColumnWidth(ideal: 350)
                        
                } detail: {
                        //  COLONNE DE DROITE (Détail)
                        if let product = selectedProduct {
                                ProductDetailView(viewModel: diContainer.makeProductDetailViewModel(product: product))
                                        .environmentObject(diContainer)
                                        .id(product.id)
                        } else {
                                VStack(spacing: 20) {
                                        Image(systemName: "tshirt")
                                                .font(.system(size: 80))
                                                .foregroundColor(.gray.opacity(0.3))
                                        Text("Sélectionnez un article\npour voir les détails")
                                                .font(.title2)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.secondary)
                                }
                        }
                }
                // Tâche de démarrage
                .task {
                        if case .idle = viewModel.state {
                                await viewModel.reload()
                        }
                }
        }
        
        // MARK: - Subviews

        @ViewBuilder
        private func loadedProductList(sections: [ProductSection]) -> some View {
                List(selection: $selectedProduct) {
                        ForEach(sections) { section in
                                Section(header:
                                                Text(section.category.capitalized)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                ) {
                                        // Le carrousel horizontal
                                        ScrollView(.horizontal, showsIndicators: false) {
                                                LazyHStack(spacing: 16) {
                                                        ForEach(section.products) { product in
                                                                Button {
                                                                        selectedProduct = product
                                                                } label: {
                                                                        ProductRowView(product: product)
                                                                                .frame(width: 170)
                                                                }
                                                                .buttonStyle(.plain)
                                                        }
                                                }
                                                .padding(.horizontal, 16)/// Annule le padding par défaut de la List pour coller aux bords
                                        }
                                        .listRowInsets(EdgeInsets()) 
                                }
                        }
                }
                .listStyle(.plain)
        }
}

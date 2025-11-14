//
//  ProductListView..swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import SwiftUI

struct ProductListView: View {
        
        @EnvironmentObject private var diContainer: AppDIContainer
        @StateObject private var viewModel: ProductListViewModel
        
        @State private var selectedProduct: Product? /// pour retenir quel produit est actuellement cliqué.

        @State private var columnVisibility = NavigationSplitViewVisibility.all
        
        init(viewModel: ProductListViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                
                
                NavigationSplitView(columnVisibility: $columnVisibility) {  /// pour lier le SPLIT VIEW à la sélection
                        
                        // ProductList
                        Group {
                                switch viewModel.state {
                                case .idle:
                                        Color.clear
                                case .loading:
                                        ProgressView("Chargement...")
                                case .error(let message):
                                        VStack(spacing: 20) {
                                                Text("Erreur: \(message)").foregroundColor(.red).multilineTextAlignment(.center)
                                                Button("Réessayer") { Task { await viewModel.reload() } }
                                                        .buttonStyle(.borderedProminent)
                                        }
                                        .padding()
                                        
                                case .loaded(let sections):
                                        
                                        List(selection: $selectedProduct) {
                                                
                                                ForEach(sections) { section in
                                                        Section(header: Text(section.category.capitalized).font(.title2).fontWeight(.bold)) {
                                                                // Carrousel horizontal DANS la liste
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
                                                                        .padding(.horizontal, -16)
                                                                }
                                                                .listRowInsets(EdgeInsets())
                                                        }
                                                }
                                        }
                                        .listStyle(.plain)
                                }
                        }
                        .navigationTitle("Catalogue")
                        .navigationSplitViewColumnWidth(ideal: 450) 
                        
                        // DetailView
                } detail: {
                        if let product = selectedProduct {
                                ProductDetailView(viewModel: diContainer.makeProductDetailViewModel(product: product))
                                        .id(product.id) ///Si l'ID du produit change, considère que c'est une vue TOTALEMENT différente et redessine-la de zéro
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
                /// Tâche de démarrage
                .task {
                        if case .idle = viewModel.state {
                                await viewModel.reload()
                        }
                }
        }
}

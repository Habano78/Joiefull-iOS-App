//
//  View.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
import SwiftUI

struct ProductListView: View {
        
        @EnvironmentObject private var diContainer: AppDIContainer
        
        @StateObject private var viewModel: ProductListViewModel
        
        init(viewModel: ProductListViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                NavigationStack {
                        Group {
                                // On "switch" sur l'état du ViewModel
                                switch viewModel.state {
                                        
                                        // CAS 1 : L'état initial
                                case .idle:
                                        Color.clear
                                        
                                        // CAS 2 : On charge
                                case .loading:
                                        ProgressView("Chargement...")
                                        
                                        // CAS 3 : On a une erreur
                                case .error(let message):
                                        VStack(spacing: 20) {
                                                Text("Erreur: \(message)")
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.center)
                                                
                                                Button("Réessayer") {
                                                        Task {
                                                                await viewModel.reload()
                                                        }
                                                }
                                                .buttonStyle(.borderedProminent)
                                        }
                                        .padding()
                                        
                                        // CAS 4 : On a les données !
                                case .loaded(let sections):
                                        
                                        // une SEULE ScrollView verticale
                                        ScrollView(.vertical, showsIndicators: false) {
                                                
                                                // VStack pour empiler les sections
                                                VStack(alignment: .leading, spacing: 24) {
                                                        
                                                        ForEach(sections, id: \.id) { section in
                                                                
                                                                // DÉBUT D'UNE SECTION
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                        Text(section.category.capitalized) /// "TOPS" -> "Tops"
                                                                                .font(.title2)
                                                                                .fontWeight(.bold)
                                                                                .padding(.horizontal)
                                                                        
                                                                        // CARROUSEL HORIZONTAL
                                                                        ScrollView(.horizontal, showsIndicators: false) {
                                                                                
                                                                                LazyHStack(spacing: 16) {
                                                                                        
                                                                                        ForEach(section.products, id: \.id) { product in
                                                                                                
                                                                                                NavigationLink(value: product as Product) {
                                                                                                        
                                                                                                        ProductRowView(product: product)
                                                                                                                .frame(width: 170)
                                                                                                }
                                                                                                .buttonStyle(.plain)
                                                                                        }
                                                                                }
                                                                                .padding(.horizontal)
                                                                                .padding(.bottom, 8)
                                                                        } // --- Fin du Carrousel ---
                                                                        
                                                                } // --- Fin d'une Section ---
                                                        }
                                                }
                                                .padding(.vertical)
                                        }
                                        // 9. On n'oublie pas notre gestionnaire de destination !
                                        .navigationDestination(for: Product.self) { product in
                                                // L'usine fabrique le VM de détail
                                                let viewModel = diContainer.makeProductDetailViewModel(product: product)
                                                // On crée la vue
                                                ProductDetailView(viewModel: viewModel)
                                        }
                                }
                        }
                        .navigationTitle("Catalogue")
                }
                .task {
                        if case .idle = viewModel.state {
                                await viewModel.reload ()
                        }
                }
        }
}

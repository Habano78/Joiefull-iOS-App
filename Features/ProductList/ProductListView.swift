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
                                case .loaded(let products):
                                        ScrollView {
                                                LazyVGrid(columns: [
                                                        GridItem(.flexible()),
                                                        GridItem(.flexible())
                                                ], spacing: 16) {
                                                        
                                                        ForEach(products) { product in
                                                                // Le 'NavigationLink' gère le clic.
                                                                        NavigationLink(value: product) {
                                                                                // Ce que l'utilisateur voit
                                                                            ProductRowView(product: product)
                                                                        }
                                                                        .buttonStyle(.plain) //
                                                        }
                                                }
                                                .padding()
                                        }
                                }
                        } 
                        .navigationTitle("Catalogue")
                }
        }
}

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
                                                        GridItem(.adaptive(minimum: 160)) ///Grille adaptative pour IPad
                                                ], spacing: 16) {
                                                        
                                                        ForEach(products) { product in
                                                                
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
                .task {
                        if case .idle = viewModel.state {
                                await viewModel.reload ()
                        }
                }
        }
}


#Preview("1. Liste Chargée (Loaded)") {
        // Crée un service factice
        let mockService = MockNetworkService()
        // Crée un VM
        let viewModel = ProductListViewModel(service: mockService)
        // FORCE l'état à ".loaded"
        viewModel.state = .loaded(MockData.products)
        
        // Crée un faux conteneur
        let diContainer = AppDIContainer()
        
        return ProductListView(viewModel: viewModel)
                .environmentObject(diContainer)
}

#Preview("2. En Chargement (Loading)") {
        let mockService = MockNetworkService()
        let viewModel = ProductListViewModel(service: mockService)
        // FORCE l'état à ".loading"
        viewModel.state = .loading
        
        let diContainer = AppDIContainer()
        
        return ProductListView(viewModel: viewModel)
                .environmentObject(diContainer)
}

#Preview("3. Erreur") {
        let mockService = MockNetworkService()
        let viewModel = ProductListViewModel(service: mockService)
        // FORCE l'état à ".error"
        viewModel.state = .error("Ceci est une erreur de preview ❌")
        
        let diContainer = AppDIContainer()
        
        return ProductListView(viewModel: viewModel)
                .environmentObject(diContainer)
}

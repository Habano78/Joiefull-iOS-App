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
        
        init(viewModel: ProductListViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                NavigationStack {
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
                                                        Task {
                                                                await viewModel.reload()
                                                        }
                                                }
                                                .buttonStyle(.borderedProminent)
                                        }
                                        .padding()
                                        
                                case .loaded(let sections):
                                        
                                        ScrollView(.vertical, showsIndicators: false) {
                                                
                                                VStack(alignment: .leading, spacing: 24) {
                                                        
                                                        ForEach(sections, id: \.id) { section in
                                                                
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                        Text(section.category.capitalized) /// "TOPS" -> "Tops"
                                                                                .font(.title2)
                                                                                .fontWeight(.bold)
                                                                                .padding(.horizontal)
                                                                        
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
                                                                        }
                                                                        
                                                                }
                                                        }
                                                }
                                                .padding(.vertical)
                                        }
                                        .navigationDestination(for: Product.self) { product in
                                                let viewModel = diContainer.makeProductDetailViewModel(product: product)
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

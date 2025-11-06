//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
//

import SwiftUI

struct ProductDetailView: View {
        
        @StateObject private var viewModel: ProductDetailViewModel
        
        //MARK: --- init ---
        
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                ZStack {
                        
                        // --- CONTENU PRINCIPAL ---
                        ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                        
                                        AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in
                                                if let image = phase.image {
                                                        image.resizable().aspectRatio(contentMode: .fit)
                                                } else if phase.error != nil {
                                                        Image(systemName: "photo.fill")
                                                } else {
                                                        ProgressView()
                                                }
                                        }
                                        
                                        Text(viewModel.product.name)
                                                .font(.largeTitle).fontWeight(.bold)
                                        
                                        Text(viewModel.product.picture.description)
                                                .font(.body).foregroundColor(.secondary)
                                        
                                        Text(String(format: "%.2f €", viewModel.product.price))
                                                .font(.title2).fontWeight(.semibold)
                                        
                                        Spacer()
                                }
                                .padding()
                        }
                        .navigationTitle(viewModel.product.name)
                        .navigationBarTitleDisplayMode(.inline)
                        
                        // --- BOUTON DE PARTAGE ---
                        .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                                // Dit au VM de COMMENCER le travail
                                                Task {
                                                        await viewModel.prepareShareableImage()
                                                }
                                        } label: {
                                                Image(systemName: "square.and.arrow.up")
                                        }
                                }
                        }
                        
                        // --- FEUILLE DE PARTAGE ---
                        .sheet(isPresented: $viewModel.isShowingShareSheet, onDismiss: {
                                viewModel.resetShareableImage()
                        }) {
                                if let image = viewModel.imageToShare {
                                        
                                        let message = "Regarde cet article sur Joiefull : \(viewModel.product.name)"
                                        
                                        // L'IMAGE EN PREMIER !
                                        ShareSheet(items: [image, message])
                                        
                                } else {
                                        Text("Erreur lors de la préparation de l'image.")
                                }
                        }
                        // --- SPINNER DE PRÉP ---
                        if viewModel.isPreparingShare {
                                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                                ProgressView("Préparation...")
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                        }
                        
                } // Fin du ZStack
        }
}

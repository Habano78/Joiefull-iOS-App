//
//  ProductDetailView.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//
import SwiftUI

struct ProductDetailView: View {
        
        
        @StateObject private var viewModel: ProductDetailViewModel
        
        //MARK: --- init ---
        
        init(viewModel: ProductDetailViewModel) {
                _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                                
                                AsyncImage(url: URL(string: viewModel.product.picture.url)) { phase in
                                        if let image = phase.image {
                                                image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                        } else if phase.error != nil {
                                                Image(systemName: "photo.fill")
                                        } else {
                                                ProgressView()
                                        }
                                }
                                
                                Text(viewModel.product.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                
                                Text(viewModel.product.picture.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                
                                Text(String(format: "%.2f €", viewModel.product.price))
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                
                                Spacer()
                        }
                        .padding()
                }
                .navigationTitle(viewModel.product.name) /// Le titre de la barre de navigation
                .navigationBarTitleDisplayMode(.inline)
        }
}

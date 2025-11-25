//
//  ProductSectionView.swift
//  Joiefull
//
//  Created by Perez William on 20/11/2025.
//

import SwiftUI

struct ProductSectionView: View, Equatable {
        
        let section: ProductSection
        let service: NetworkServiceProtocol
        let onProductSelected: (Product) -> Void
        
        // Optimisation : si la section n’a pas changé, elle ne se reconstruit pas
        static func == (lhs: ProductSectionView, rhs: ProductSectionView) -> Bool {
                lhs.section == rhs.section
        }
        
        var body: some View {
                
                Section(header: sectionHeader) {
                        ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(alignment: .top, spacing: 16) {
                                        ForEach(section.products) { product in
                                                
                                                Button {
                                                        onProductSelected(product)
                                                } label: {
                                                        ProductRowView(
                                                                product: product,
                                                                service: service
                                                        )
                                                        .equatable()
                                                        .frame(width: 170, height: 260, alignment: .top)
                                                       
                                                }
                                                .buttonStyle(.plain)
                                                .id(product.id) // Stabilise chaque cellule
                                        }
                                }
                                .padding(.horizontal, 16)
                        }
                        .listRowInsets(EdgeInsets())
                }
        }
        
        private var sectionHeader: some View {
                Text(section.category.capitalized)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
        }
}

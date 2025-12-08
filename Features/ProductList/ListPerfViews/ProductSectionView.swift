//
//  ProductSectionView.swift
//  Joiefull
//
//  Created by Perez William on 20/11/2025.
//

import SwiftUI

struct ProductSectionView: View, Equatable {
        
        //MARK: Properties
        let section: ProductSection
        let service: NetworkServiceProtocol
        let onProductSelected: (Product) -> Void
        
        //MARK: Equatable
        /// Optimisation : si la section n’a pas changé, elle ne se reconstruit pas
        static func == (lhs: ProductSectionView, rhs: ProductSectionView) -> Bool {
                lhs.section == rhs.section
        }
        
        //MARK: Body
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
                                                .id(product.id) /// Stabilisateur
                                        }
                                }
                                .padding(.horizontal, 16)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
        }
        
        private var sectionHeader: some View {
                Text(section.category.capitalized)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.leading, 16) /// du padding pour que le titre ne colle pas trop
                        .padding(.bottom, 4)
                        .padding(.top, 4)
                        .listRowInsets(EdgeInsets()) /// Important pour maîtriser l'alignement du header
        }
}

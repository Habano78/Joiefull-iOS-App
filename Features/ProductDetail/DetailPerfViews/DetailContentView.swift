//
//  ProductDetailContentView.swift
//  Joiefull
//
//  Created by Perez William on 12/11/2025.
//

import SwiftUI

struct DetailContentView: View, Equatable {
        
        // MARK: - Properties
        let product: Product
        let accessibilityPriceDescription: String
        @Binding var userRating: Int
        @Binding var userComment: String
        let onSubmitReview: () -> Void /// Action pour le bouton
        
        static func == (lhs: DetailContentView, rhs: DetailContentView) -> Bool {
                return lhs.product.id == rhs.product.id &&
                lhs.userRating == rhs.userRating &&
                lhs.userComment == rhs.userComment
                /// Si le texte change, userComment change, donc return FALSE -> Redessin
        }
        // MARK: - Body
        var body: some View {
                
                let _ = print ("2. DateilContentView se redessine")
                
                VStack(alignment: .leading, spacing: 20) {
                        
                        // Infos du produit
                        ProductInfoView(
                                product: product,
                                accessibilityPriceDescription: accessibilityPriceDescription
                        )
                        
                        Divider()
                        
                        // AVIS formulaire
                        VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("SECTION_REVIEWS_TITLE", comment: ""))
                                        .font(.headline)
                                
                                // Étoiles
                                HStack {
                                        StarRatingView(rating: $userRating)
                                        Spacer()
                                        Text("\(userRating)/5").foregroundColor(.secondary)
                                }
                                
                                // Champ Texte
                                TextEditor(text: $userComment)
                                        .frame(height: 100)
                                        .padding(4)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                                
                                // Bouton Envoyer
                                Button {
                                        onSubmitReview()
                                } label: {
                                        Text(NSLocalizedString("SUBMIT_REVIEW_BUTTON", comment: ""))
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.joiefullPrimary)
                                                .foregroundColor(.white)
                                                .cornerRadius(12)
                                }
                                .disabled(userRating == 0)
                                .opacity(userRating == 0 ? 0.6 : 1)
                        }
                }
                .padding(.bottom, 40)
        }
}

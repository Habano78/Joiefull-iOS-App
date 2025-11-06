//
//  ViewModel.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
        
        // MARK: - Properties
        
        @Published var product: Product
        private let service: NetworkServiceProtocol
        
        @Published var isShowingShareSheet = false /// Trigger de Sheet
        @Published private(set) var imageToShare: UIImage? ///Image télécharhgée pour la view
        
        @Published private(set) var isPreparingShare = false
        
        init(product: Product, service: NetworkServiceProtocol) {
                self.product = product
                self.service = service
        }
        
        // MARK: - Download + Prepare
        
        func prepareShareableImage() async {
                
                self.isPreparingShare = true
                defer { self.isPreparingShare = false }
                
                do {
                        // demande au service de télécharger l'image
                        let image = try await service.downloadImage(
                                from: product.picture.url
                        )
                        
                        // stocke l'image ET on active le trigger
                        self.imageToShare = image
                        self.isShowingShareSheet = true // Trigger
                        
                } catch let error as NetworkError {
                        // (On pourrait aussi publier cette erreur à la vue)
                        print("Erreur de téléchargement d'image: \(error.errorDescription ?? "")")
                        self.imageToShare = nil
                } catch {
                        print("Erreur inconnue: \(error.localizedDescription)")
                        self.imageToShare = nil
                }
        }
        
        // MARK: - Reset
        
        func resetShareableImage() {
                imageToShare = nil
                isShowingShareSheet = false
        }
}

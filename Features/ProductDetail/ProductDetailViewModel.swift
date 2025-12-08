//
//  ProductDetailViewModel.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine


@MainActor
final class ProductDetailViewModel: ObservableObject {
        
        // MARK: Dependencies
        let service: NetworkServiceProtocol
        
        // MARK: Published Properties
        @Published var product: Product
        @Published var favoriteStatus: ProductDetailFavoriteStatus
        
        // Gestion du Partage (Architecture Robuste)
        @Published var activeShareItem: ShareItem? = nil
        @Published private(set) var isLoadingImage = false
        
        // Gestion des Erreurs
        @Published var shareError: Error?
        @Published var isShowingErrorAlert = false
        
        // Formulaire Avis
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        // Cache interne pour l'image
        var cachedImage: UIImage?
        
        // MARK: - Init
        init(product: Product, service: NetworkServiceProtocol) {
                self.product = product
                self.service = service
                self.favoriteStatus = ProductDetailFavoriteStatus(
                        isFavorite: false,
                        likesCount: product.likes
                )
                Task { await preloadImage() }
        }
        
        // MARK: - Actions Utilisateur
        
        func toggleFavorite() {
                favoriteStatus.toggle()
        }
        
        // MARK: - Gestion du Partage
        
        /// Fonction appelée au clic du bouton
        func ShareButtonTapped() async {
                
                guard !isLoadingImage else { return }
                
                // 1. Si l'image est déjà en cache, on affiche direct
                if let image = cachedImage {
                        showSheet(with: image)
                        return
                }
                
                // 2. Sinon, on télécharge
                isLoadingImage = true
                shareError = nil // Reset erreur précédente
                
                defer { isLoadingImage = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        self.cachedImage = image // On sauvegarde pour la prochaine fois
                        showSheet(with: image)
                } catch {
                        print("Erreur téléchargement image partage: \(error)")
                        self.shareError = error
                        self.isShowingErrorAlert = true
                }
        }
        
        // Méthode privée pour précharger sans bloquer l'UI
        func preloadImage() async {
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        self.cachedImage = image
                } catch {
                        /// Silencieux
                }
        }
        
        // Helper pour construire l'objet ShareItem et ouvrir la sheet
        private func showSheet(with image: UIImage) {
                let message = "Regarde cet article sur Joiefull : \(product.name)"
                // L'assignation de cette variable déclenche l'ouverture de la sheet dans la Vue
                self.activeShareItem = ShareItem(image: image, message: message)
        }
        
}

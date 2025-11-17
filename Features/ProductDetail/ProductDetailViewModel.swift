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
class ProductDetailViewModel: ObservableObject {
        
        // MARK: - Propriétés
        
        //Pour le vue
        @Published var product: Product
        private let service: NetworkServiceProtocol
        
        // Partage
        @Published var isShowingShareSheet = false
        @Published private(set) var imageToShare: UIImage?
        @Published private(set) var isPreparingShare = false
        
        // Avis
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        // Favoris / likes
        @Published var isFavorite: Bool = false
        @Published var likesCounting: Int
        
        // Préchargement
        private var isPreloadingShare = false
        
        
        // MARK: - Init
        
        init(product: Product,
             service: NetworkServiceProtocol,
             autoPreload: Bool = true) {
                self.product = product
                self.service = service
                self.likesCounting = product.likes
                
                if autoPreload {
                        Task { [weak self] in
                                await self?.preloadShareableImage()
                        }
                }
        }
        
        //Favoris
        func toggleFavorite() {
                isFavorite.toggle()
                
                if isFavorite {
                        likesCounting += 1
                } else {
                        likesCounting -= 1
                }
        }
        
        // Préchargement de l'image. Pour télécharger l'image en avance
        func preloadShareableImage() async {
                guard imageToShare == nil,
                      !isPreparingShare,
                      !isPreloadingShare else { return }
                
                isPreloadingShare = true
                defer { isPreloadingShare = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        imageToShare = image
                } catch {
                        imageToShare = nil
                }
        }
        
        // Télécharger + ouvrir la feuille de partage
        func prepareShareableImage() async {
                
                guard !isPreparingShare,
                      !isPreloadingShare else { return } /// Empêche les double-clics rapides
                
                isPreparingShare = true
                defer { isPreparingShare = false }
        
                if imageToShare != nil {
                        isShowingShareSheet = true /// Si l'image est déjà préchargée, on ouvre juste la feuille
                        return
                }
                
                do {
                        let image = try await service.downloadImage(
                                from: product.picture.url
                        )
                        
                        try Task.checkCancellation()
                        
                        imageToShare = image
                        isShowingShareSheet = true
                        
                } catch is CancellationError { /// si la tâche a été annulée, on laisse tout à nil
                        imageToShare = nil
                } catch is NetworkError {
                        imageToShare = nil
                } catch {
                        imageToShare = nil
                }
        }
        
        // Bouton de partage
        func handleShareButtonTapped() async {
                if imageToShare != nil {
                        isShowingShareSheet = true
                } else {
                       
                        await prepareShareableImage()
                }
        }
        
        // MARK: - Reset
        func resetShareableImage() {
                isShowingShareSheet = false /// Ferme la feuille de partage **sans** effacer l'image du cache.
        }
}


        //Note:  Parameter autoPreload:
///   true (défaut) → l'image est préchargée automatiquement en prod.
///   false → les tests contrôlent manuellement le préchargement.

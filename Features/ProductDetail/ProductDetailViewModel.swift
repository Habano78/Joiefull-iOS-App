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
        
        // MARK: - Propriétés exposées à la vue
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
        
        // MARK: Methodes
        
        // FAVORIS
        func toggleFavorite() {
                isFavorite.toggle()
                
                if isFavorite {
                        likesCounting += 1
                } else {
                        likesCounting -= 1
                }
        }
        
        // Préchargement de l'image : appelée pour télécharger l'image en avance, sans ouvrir la sheet
        func preloadShareableImage() async {
                
                guard imageToShare == nil, ///Si on a déjà une image, ou si un download est en cours → ne rien faire
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
                      !isPreloadingShare else { return }
                
                isPreparingShare = true
                defer { isPreparingShare = false }
                
                if imageToShare != nil {
                        isShowingShareSheet = true
                        return
                }
                
                do {
                        let image = try await service.downloadImage(
                                from: product.picture.url
                        )
                        
                        try Task.checkCancellation()
                        
                        imageToShare = image
                        isShowingShareSheet = true
                        
                } catch is CancellationError {
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
                        isShowingShareSheet = true ///Si l'image est déjà prête → on ouvre directement
                } else {
                        
                        await prepareShareableImage() ///Sinon → on télécharge avec spinner
                }
        }
        
        //Reset
        func resetShareableImage() {
                isShowingShareSheet = false /// Ferme la feuille de partage **sans** effacer l'image du cache.
        }
}


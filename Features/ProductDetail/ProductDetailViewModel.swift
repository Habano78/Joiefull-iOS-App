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
        
        //Dépendances
        @Published var product: Product
        private let service: NetworkServiceProtocol
        
        // Sheet
        @Published var isShowingShareSheet = false
        @Published private(set) var imageToShare: UIImage?
        @Published private(set) var isPreparingShare = false
        
        // Avis
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        // Favoris
        @Published var isFavorite: Bool = false
        
        // Pour éviter de lancer plusieurs préchargements
        private var isPreloadingShare = false
        
        //likes count
        @Published var likesCount: Int = 0
        @Published var isLiked: Bool = false
        
        // MARK: - Init
        init(product: Product, service: NetworkServiceProtocol) {
                self.product = product
                self.service = service
                self.likesCount = product.likes
                
                Task {
                        await self.preloadShareableImage() ///telech dirct
                }
        }
        
        
        // MARK: - Favoris
        func toggleFavorite() {
                isFavorite.toggle()
                
                if isFavorite {
                        likesCount += 1
                } else {
                        likesCount -= 1
                }
        }
        
        
        // MARK: - Préchargement de l'image
        /// Appelée quand la vue apparaît, pour télécharger l'image en avance
        func preloadShareableImage() async {
                // Si on a déjà une image, ou si on est en train de préparer/ précharger → ne rien faire
                guard imageToShare == nil,
                      !isPreparingShare,
                      !isPreloadingShare
                else { return }
                
                isPreloadingShare = true
                defer { isPreloadingShare = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        // On ne montre PAS la sheet ici : on prépare juste
                        imageToShare = image
                } catch {
                        // On ignore l'erreur ici : on se rattrapera au moment du partage
                        imageToShare = nil
                }
        }
        
        
        // MARK: - Télécharger + ouvrir la feuille de partage
        func prepareShareableImage() async {
                
                // Empêche les double-clics rapides
                guard !isPreparingShare,!isPreloadingShare
                else { return }
                
                isPreparingShare = true
                defer { isPreparingShare = false }
                
                // Si l'image est déjà préchargée, on ouvre juste la feuille
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
                        // la tâche a été annulée, on laisse tout à nil
                        imageToShare = nil
                } catch is NetworkError {
                        imageToShare = nil
                } catch {
                        imageToShare = nil
                }
        }
        
        // Logique centrale du bouton de partage
        func handleShareButtonTapped() async {
                // Si l'image est déjà prête -→ on ouvre directement
                if imageToShare != nil {
                        isShowingShareSheet = true
                } else {
                        // Sinon → on télécharge avec spinner
                        await prepareShareableImage()
                }
        }
        
        // MARK: - Reset
        func resetShareableImage() {
                isShowingShareSheet = false /// close sheet
        }
}

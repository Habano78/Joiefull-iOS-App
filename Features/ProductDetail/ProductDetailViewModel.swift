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
        
        // MARK: Service
        let service: NetworkServiceProtocol
        
        //MARK: Published
        @Published var product: Product
        @Published var favoriteStatus: ProductDetailFavoriteStatus
       
        @Published var isShowingShareSheet = false
        @Published private(set) var imageToShare: UIImage?
        @Published private(set) var isPreparingShare = false
        
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        @Published var shareError: Error?
        
        private var isPreloadingShare = false
        
        
        // MARK: - Init
        init(product: Product, service: NetworkServiceProtocol) {
                self.product = product
                self.service = service
                self.favoriteStatus = ProductDetailFavoriteStatus(
                        isFavorite: false,
                        likesCount: product.likes
                )
                
                
                // PRELOAD de l'ilmage au moment de la création du ViewModel
                Task { await preloadShareableImage() }
        }
        
        
        // MARK: - Préchargement
        func preloadShareableImage() async {
                guard imageToShare == nil,
                      !isPreparingShare,
                      !isPreloadingShare else { return }
                
                isPreloadingShare = true
                defer { isPreloadingShare = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        self.imageToShare = image
                } catch {
                        self.imageToShare = nil
                }
        }
        
        // MARK: - Ouverture feuille de partage
        func handleShareButtonTapped() async {
                if let _ = imageToShare {
                        isShowingShareSheet = true
                } else {
                        await prepareShareableImage()
                }
        }
        
        private func prepareShareableImage() async {
                guard !isPreparingShare else { return }
                
                isPreparingShare = true
                defer { isPreparingShare = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        self.imageToShare = image
                        self.isShowingShareSheet = true
                        self.shareError = nil // ⬅️ Succès
                } catch {
                        self.imageToShare = nil
                        self.shareError = error // ⬅️ Échec
                }
        }
        
        func resetShareableImage() {
                isShowingShareSheet = false
        }
}

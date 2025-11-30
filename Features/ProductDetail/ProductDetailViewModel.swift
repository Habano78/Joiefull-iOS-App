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
      
        @Published private(set) var imageReadyToShare: UIImage?
        @Published var isShowingShareSheet = false /// pour savoir quand afficher ou masquer la sheet
        @Published private(set) var isLoadingImage = false /// telechargement en cours
        
        private var isAlreadyPreloading = false /// empecher les telechargement repetés
        
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        @Published var shareError: Error?
        
        func toggleFavorite() {
                favoriteStatus.toggle()
        }
        
        // MARK: - Init
        init(product: Product, service: NetworkServiceProtocol, autoPreload: Bool = true) {
                self.product = product
                self.service = service
                self.favoriteStatus = ProductDetailFavoriteStatus(
                        isFavorite: false,
                        likesCount: product.likes
                )
                if autoPreload {
                        Task { await preloadShareableImage() }
                }
        }
        
        
        // MARK: - Préchargement
        func preloadShareableImage() async {
                guard imageReadyToShare == nil,
                      !isLoadingImage,
                      !isAlreadyPreloading else { return }
                
                isAlreadyPreloading = true
                defer { isAlreadyPreloading = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        self.imageReadyToShare = image
                } catch {
                        self.imageReadyToShare = nil
                }
        }
        
        // MARK: - Ouverture feuille de partage
        func handleShareButtonTapped() async {
                if let _ = imageReadyToShare {
                        isShowingShareSheet = true
                } else {
                        await prepareShareableImage()
                }
        }
        
        func prepareShareableImage() async {
                guard !isLoadingImage else { return }
                
                isLoadingImage = true
                defer { isLoadingImage = false }
                
                do {
                        let image = try await service.downloadImage(from: product.picture.url)
                        try Task.checkCancellation()
                        self.imageReadyToShare = image
                        self.isShowingShareSheet = true
                        self.shareError = nil /// Succès
                } catch {
                        self.imageReadyToShare = nil
                        self.shareError = error /// Échec
                }
        }
        
        func resetShareableImage() {
                isShowingShareSheet = false
        }
}

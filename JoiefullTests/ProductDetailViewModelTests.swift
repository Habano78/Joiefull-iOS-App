//
//  ProductDetailViewModelTests.swift
//  JoiefullTests
//
//  Created by Perez William on 12/11/2025.
//

import Testing
import SwiftUI
@testable import Joiefull

final class ProductDetailViewModelTests {
        
        var sut: ProductDetailViewModel!
        var mockService: MockNetworkService!
        
        // MARK: - Setup commun
        @MainActor
        func setup() {
                mockService = MockNetworkService()
                sut = ProductDetailViewModel(
                        product: mockTestProduct,
                        service: mockService
                )
        }
        
        // MARK: - Toggle Favorite Tests
        @Test("Vérifie que le favori passe de off à on et incrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOff_ShouldTurnOnAndIncrementLikes() {
                setup()
                
                // GIVEN
                #expect(sut.favoriteStatus.isFavorite == false)
                #expect(sut.favoriteStatus.likesCount == mockTestProduct.likes)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.favoriteStatus.isFavorite == true)
                #expect(sut.favoriteStatus.likesCount == mockTestProduct.likes + 1)
        }
        
        @Test("Vérifie que le favori passe de ON à OFF et décrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOn_ShouldTurnOffAndDecrementLikes() {
                setup()
                
                // GIVEN
                sut.favoriteStatus = ProductDetailFavoriteStatus(
                        isFavorite: true,
                        likesCount: mockTestProduct.likes + 1
                )
                #expect(sut.favoriteStatus.isFavorite == true)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.favoriteStatus.isFavorite == false)
                #expect(sut.favoriteStatus.likesCount == mockTestProduct.likes)
        }
        
        // MARK: - Image Sharing Tests
        
        @Test("Préchargement télécharge l'image sans ouvrir la sheet")
        @MainActor
        func testPreloadShareableImage_WhenSuccess() async {
               setup()
                
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.activeShareItem == nil)
                
                // WHEN
                await sut.preloadImage()
                
                // THEN
                #expect(sut.activeShareItem == nil)
                #expect(mockService.downloadImageCallCount == 2)
        }
        
        @Test("Partage réussit et met à jour l'état")
        @MainActor
        func testShareButtonTapped_WhenSuccess() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.activeShareItem == nil)
                
                // WHEN
                await sut.ShareButtonTapped()
                
                // THEN
                #expect(sut.isLoadingImage == false)
                #expect(sut.activeShareItem != nil)
        }
        
        @Test("Appels concurrents : téléchargement ne se fait qu'une fois")
        @MainActor
        func testShareButtonTapped_WhenCalledConcurrently_ShouldDownloadOnce() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(mockService.downloadImageCallCount == 0)
                
                // WHEN
                await withTaskGroup(of: Void.self) { group in
                        group.addTask { await self .sut.ShareButtonTapped() }
                        group.addTask { await self .sut.ShareButtonTapped() }
                }
                
                // THEN
                #expect(mockService.downloadImageCallCount == 2)
                #expect(sut.activeShareItem != nil)
        }
        
        @Test("Si image déjà préchargée, pas de nouveau téléchargement")
        @MainActor
        func testShareButtonTapped_WhenImageAlreadyPreloaded_ShouldNotRedownload() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.preloadImage()
                #expect(mockService.downloadImageCallCount == 2)
                #expect(sut.activeShareItem == nil)
                
                // WHEN
                await sut.ShareButtonTapped()
                
                // THEN
                #expect(sut.activeShareItem != nil)
                #expect(mockService.downloadImageCallCount == 2)
        }
        
        @Test("Échec réseau empêche l'ouverture de la sheet")
        @MainActor
        func testShareButtonTapped_WhenNetworkFails() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .failure(NetworkError.serverError(statusCode: 404))
                
                // WHEN
                await sut.ShareButtonTapped()
                
                // THEN
                #expect(sut.isLoadingImage == false)
                #expect(sut.activeShareItem == nil)
        }
        
        @Test("Tâche annulée empêche l'ouverture de la sheet")
        @MainActor
        func testShareButtonTapped_WhenTaskIsCancelled() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .failure(CancellationError())
                
                // WHEN
                await sut.ShareButtonTapped()
                
                // THEN
                #expect(sut.isLoadingImage == false)
                #expect(sut.activeShareItem == nil)
        }
        
        struct UnknownTestError: Error {}
        @Test("Erreur inconnue empêche l'ouverture de la sheet")
        @MainActor
        func testShareButtonTapped_WhenUnknownError() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .failure(UnknownTestError())
                
                // WHEN
                await sut.ShareButtonTapped()
                
                // THEN
                #expect(sut.isLoadingImage == false)
                #expect(sut.activeShareItem == nil)
        }
        
        @Test("Reset de la sheet ferme la sheet mais garde l'image en cache")
        @MainActor
        func testResetShareableImage_ShouldKeepImage() async {
                setup()
                
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.ShareButtonTapped()
                #expect(sut.activeShareItem != nil)
                
                // WHEN
                sut.activeShareItem = nil // reset sheet
                
                // THEN
                #expect(sut.activeShareItem == nil)
                #expect(sut.cachedImage != nil)
        }
}

//
//  ProductDetailViewModelTests.swift
//  JoiefullTests
//
//  Created by Perez William on 12/11/2025.
//


import Testing
import SwiftUI
@testable import Joiefull

struct ProductDetailViewModelTests {
        
        var sut: ProductDetailViewModel
        var mockService: MockNetworkService
        
        // MARK: - Setup
        
        @MainActor
        init() {
                mockService = MockNetworkService()
                // 🔹 autoPreload = false pour garder le contrôle dans les tests
                sut = ProductDetailViewModel(
                        product: mockTestProduct,
                        service: mockService,
                        autoPreload: false
                )
        }
        
        
        //
        @Test("Vérifie que le favori passe de off à on et incrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOff_ShouldTurnOnAndIncrementLikes() {
                // GIVEN
                #expect(sut.favoriteState.isFavorite == false)
                #expect(sut.favoriteState.likesCount == mockTestProduct.likes)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.favoriteState.isFavorite == true)
                #expect(sut.favoriteState.likesCount == mockTestProduct.likes + 1)
        }
        
        //
        @Test("Vérifie que le favori passe de ON à OFF et décrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOn_ShouldTurnOffAndDecrementLikes() {
                // GIVEN
                sut.favoriteState = ProductDetailFavoriteStatus(
                        isFavorite: true,
                        likesCount: mockTestProduct.likes + 1
                )
                #expect(sut.favoriteState.isFavorite == true)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.favoriteState.isFavorite == false)
                #expect(sut.favoriteState.likesCount == mockTestProduct.likes)
        }
        
        
        //
        @Test("Vérifie que le préchargement télécharge l'image sans ouvrir la feuille de partage")
        @MainActor
        func testPreloadShareableImage_WhenSuccess() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.imageToShare == nil)
                #expect(sut.isShowingShareSheet == false)
                
                // WHEN
                await sut.preloadShareableImage()
                
                // THEN
                #expect(sut.imageToShare != nil)
                #expect(sut.isShowingShareSheet == false)
                #expect(mockService.downloadImageCallCount == 1)
        }
        
        
        //
        @Test("Vérifie que le partage réussit et met à jour l'état")
        @MainActor
        func testPrepareShareableImage_WhenSuccess() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
                
                // WHEN
                await sut.prepareShareableImage()
                
                // THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
                #expect(mockService.downloadImageCallCount == 1)
        }
        
        
        //
        @Test("Vérifie que le partage ne se lance qu'une fois en cas d’appels concurrents")
        @MainActor
        func testPrepareShareableImage_WhenCalledConcurrently_ShouldDownloadOnce() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(mockService.downloadImageCallCount == 0)
                
                // WHEN
                async let first = sut.prepareShareableImage()
                async let second = sut.prepareShareableImage()
                _ = await (first, second)
                
                // THEN
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
        }
        
        
        //
        @Test("Vérifie que handleShareButtonTapped n'effectue pas un nouveau téléchargement si l'image est déjà préchargée")
        @MainActor
        func testHandleShareButtonTapped_WhenImageAlreadyPreloaded_ShouldNotRedownload() async {
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.preloadShareableImage()
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.imageToShare != nil)
                #expect(sut.isShowingShareSheet == false)
                
                // WHEN
                await sut.handleShareButtonTapped()
                
                // THEN
                #expect(sut.isShowingShareSheet == true)
                #expect(mockService.downloadImageCallCount == 1) // pas de nouveau téléchargement
        }
        
        
        //
        @Test("Vérifie que le partage ne s'ouvre pas en cas d'erreur réseau")
        @MainActor
        func testPrepareShareableImage_WhenNetworkFails() async {
                // GIVEN
                mockService.downloadImageResult = .failure(NetworkError.serverError(statusCode: 404))
                
                // WHEN
                await sut.prepareShareableImage()
                
                // THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
        }
        
        //
        @Test("Vérifie que le partage ne s'ouvre pas si la tâche est annulée")
        @MainActor
        func testPrepareShareableImage_WhenTaskIsCancelled() async {
                // GIVEN
                mockService.downloadImageResult = .failure(CancellationError())
                
                // WHEN
                await sut.prepareShareableImage()
                
                // THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
        }
        
        struct UnknownTestError: Error { }
        
        //
        @Test("Vérifie que le partage ne s'ouvre pas en cas d'erreur inconnue")
        @MainActor
        func testPrepareShareableImage_WhenUnknownError() async {
                // GIVEN
                mockService.downloadImageResult = .failure(UnknownTestError())
                
                // WHEN
                await sut.prepareShareableImage()
                
                // THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
        }
        
        
        //
        @Test("Vérifie que resetShareableImage ferme la sheet mais garde l'image en cache")
        @MainActor
        func testResetShareableImage_WhenStateIsDirty_ShouldKeepImage() async {
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.prepareShareableImage()
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
                
                // WHEN
                sut.resetShareableImage()
                
                // THEN
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare != nil) // ✅ on garde l'image en cache
        }
}

//Ce que ces tests couvrent
///* *Favoris (toggle + likes qui montent/descendent)
///* * Préchargement de l’image de partage (sans ouvrir la sheet)
///* *Succès du partage (image téléchargée + sheet affichée)
/// * * Protection contre les appels concurrents (prepareShareableImage appelé deux fois)
///* * handleShareButtonTapped qui ne redéclenche pas un téléchargement si l’image est prête
/// * * Erreurs : réseau, annulation, erreur inconnue
/// * *resetShareableImage qui ferme la sheet mais garde l'image pour un partage fluide ensuite

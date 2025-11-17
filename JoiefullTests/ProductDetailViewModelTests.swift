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
                sut = ProductDetailViewModel(
                        product: mockTestProduct,
                        service: mockService,
                        autoPreload: false      // 👈 important : pas de préchargement auto en tests
                )
        }
        
        // MARK: --- Tests Favoris / Likes ---
        
        @Test("Vérifie que l'état favori bascule de 'off' à 'on' et incrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOff_ShouldTurnOn() {
                // GIVEN
                #expect(sut.isFavorite == false)
                let initialLikes = sut.likesCounting
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.isFavorite == true)
                #expect(sut.likesCounting == initialLikes + 1)
        }
        
        @Test("Vérifie que l'état favori bascule de 'on' à 'off' et décrémente les likes")
        @MainActor
        func testToggleFavorite_WhenOn_ShouldTurnOff() {
                // GIVEN
                sut.isFavorite = true
                sut.likesCounting = sut.product.likes + 1
                #expect(sut.isFavorite == true)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.isFavorite == false)
                #expect(sut.likesCounting == sut.product.likes)
        }
        
        // MARK: --- Tests Partage (Succès) ---
        
        @Test("Vérifie que le partage réussit et met à jour l'état")
        @MainActor
        func testPrepareShareableImage_WhenSuccess() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
                #expect(mockService.downloadImageCallCount == 0)
                
                // WHEN
                await sut.prepareShareableImage()
                
                // THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
                #expect(mockService.downloadImageCallCount == 1)
        }
        
        @Test("Vérifie que le partage ne se lance qu'une fois en cas de 'double-clic'")
        @MainActor
        func testPrepareShareableImage_WhenCalledConcurrently() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(mockService.downloadImageCallCount == 0)
                
                // WHEN
                async let firstCall = sut.prepareShareableImage()
                async let secondCall = sut.prepareShareableImage()
                let _ = await (firstCall, secondCall)
                
                // THEN
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.isShowingShareSheet == true)
        }
        
        // MARK: --- Tests Partage (Échecs) ---
        
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
        
        // MARK: --- Tests Reset ---
        
        @Test("Vérifie que la fonction 'reset' ferme la sheet mais garde l'image en cache")
        @MainActor
        func testResetShareableImage_WhenStateIsDirty() async {
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.prepareShareableImage()
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
                
                // WHEN
                sut.resetShareableImage()
                
                // THEN
                #expect(sut.isShowingShareSheet == false)
                // 👉 nouvelle logique : l'image reste en cache
                #expect(sut.imageToShare != nil)
        }
        
        // MARK: --- Tests Préchargement & handleShareButtonTapped ---
        
        @Test("Vérifie que le préchargement télécharge l'image sans ouvrir la feuille de partage")
        @MainActor
        func testPreloadShareableImage_WhenSuccess() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.imageToShare == nil)
                #expect(sut.isShowingShareSheet == false)
                #expect(mockService.downloadImageCallCount == 0)
                
                // WHEN
                await sut.preloadShareableImage()
                
                // THEN
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.imageToShare != nil)
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.isPreparingShare == false)
        }
        
        @Test("Vérifie que handleShareButtonTapped n'effectue pas un nouveau téléchargement si l'image est déjà préchargée")
        @MainActor
        func testHandleShareButtonTapped_WhenImageAlreadyPreloaded() async {
                // GIVEN
                mockService.downloadImageResult = .success
                await sut.preloadShareableImage()
                #expect(sut.imageToShare != nil)
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.isShowingShareSheet == false)
                
                // WHEN
                await sut.handleShareButtonTapped()
                
                // THEN
                #expect(sut.isShowingShareSheet == true)
                // Pas de nouveau téléchargement
                #expect(mockService.downloadImageCallCount == 1)
        }
        
        @Test("Vérifie que l'init avec autoPreload lance le préchargement de l'image")
        @MainActor
        func testInit_WithAutoPreload_ShouldPreloadImage() async {
                // GIVEN
                mockService.downloadImageResult = .success
                
                // WHEN : on crée un ViewModel AVEC autoPreload = true
                let autoPreloadViewModel = ProductDetailViewModel(
                        product: mockTestProduct,
                        service: mockService,
                        autoPreload: true
                )
                
                // On laisse le temps à la Task de se terminer
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1,5s (mock = 1s)
                
                // THEN
                #expect(self.mockService.downloadImageCallCount == 1)
                #expect(autoPreloadViewModel.imageToShare != nil)
        }
        
        @Test("Vérifie que le préchargement en erreur garde imageToShare à nil")
        @MainActor
        func testPreloadShareableImage_WhenUnknownError_ShouldKeepImageNil() async {
                // GIVEN
                mockService.downloadImageResult = .failure(UnknownTestError())
                #expect(sut.imageToShare == nil)
                
                // WHEN
                await sut.preloadShareableImage()
                
                // THEN
                #expect(mockService.downloadImageCallCount == 1)
                #expect(sut.imageToShare == nil)    // 👈 branche catch { imageToShare = nil }
        }
        
        @Test("Vérifie que prepareShareableImage n'effectue pas un nouveau téléchargement si l'image est déjà préchargée")
        @MainActor
        func testPrepareShareableImage_WhenImageAlreadyThere_ShouldNotDownloadAgain() async {
                // GIVEN : on précharge une première fois
                mockService.downloadImageResult = .success
                await sut.preloadShareableImage()
                #expect(sut.imageToShare != nil)
                #expect(mockService.downloadImageCallCount == 1)
                
                // WHEN : on appelle à nouveau prepareShareableImage
                await sut.prepareShareableImage()
                
                // THEN : la sheet doit s'ouvrir, mais pas de nouveau download
                #expect(sut.isShowingShareSheet == true)
                #expect(mockService.downloadImageCallCount == 1)
        }
        
        @Test("Vérifie que handleShareButtonTapped déclenche un téléchargement quand l'image n'est pas préchargée")
        @MainActor
        func testHandleShareButtonTapped_WhenNoImage_ShouldTriggerDownload() async {
                // GIVEN
                mockService.downloadImageResult = .success
                #expect(sut.imageToShare == nil)
                #expect(mockService.downloadImageCallCount == 0)
                #expect(sut.isShowingShareSheet == false)
                
                // WHEN
                await sut.handleShareButtonTapped()
                
                // THEN
                #expect(mockService.downloadImageCallCount == 1)  // appel via prepareShareableImage()
                #expect(sut.imageToShare != nil)
                #expect(sut.isShowingShareSheet == true)
        }
        
}


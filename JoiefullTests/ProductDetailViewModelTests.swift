//
//  ProductDetailViewModelTests.swift
//  JoiefullTests
//
//  Created by Perez William on 13/11/2025.
//

import Testing
import SwiftUI
@testable import Joiefull

struct ProductDetailViewModelTests {
        
        var sut: ProductDetailViewModel
        var mockService: MockNetworkService
        
        @MainActor
        init() {
                mockService = MockNetworkService()
                sut = ProductDetailViewModel(
                        product: mockTestProduct,
                        service: mockService
                )
        }
        
        //MARK: --- Tests Favoris ---
        
        @Test("Vérifie que l'état favori bascule de 'off' à 'on'")
        @MainActor
        func testToggleFavorite_WhenOff_ShouldTurnOn() {
                // GIVEN
                #expect(sut.isFavorite == false)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.isFavorite == true)
        }
        
        @Test("Vérifie que l'état favori bascule de 'on' à 'off'")
        @MainActor
        func testToggleFavorite_WhenOn_ShouldTurnOff() {
                // GIVEN
                sut.isFavorite = true
                #expect(sut.isFavorite == true)
                
                // WHEN
                sut.toggleFavorite()
                
                // THEN
                #expect(sut.isFavorite == false)
        }
        
        //MARK: --- Tests Partage (Succès) ---
        
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
        
        //MARK: --- Tests Partage (Échecs) ---
        
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
        
        //MARK: --- Tests Reset ---
        
        @Test("Vérifie que la fonction 'reset' nettoie bien l'état")
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
                #expect(sut.imageToShare == nil)
        }
}

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
                sut = ProductDetailViewModel(product: mockTestProduct,service: mockService)
        }
        
        //MARK: Vérifier que le favori s'active
        @Test
        @MainActor
        func testToggleFavorite_WhenOff_ShouldTurnOn() {
                
                // 1. GIVEN (Étant donné)
                // Notre 'init()' a préparé le 'sut'.
                // On vérifie que l'état initial est bien 'false'.
                #expect(sut.isFavorite == false)
                
                // 2. WHEN (Quand)
                // On exécute l'action.
                sut.toggleFavorite()
                
                // 3. THEN (Alors)
                // On vérifie que l'état a changé.
                #expect(sut.isFavorite == true)
        }
        
        // Test 2: Vérifier qu'il se désactive aussi
        @Test
        @MainActor
        func testToggleFavorite_WhenOn_ShouldTurnOff() {
                
                // 1. GIVEN (Étant donné)
                // On met manuellement l'état à 'true' pour ce test.
                sut.isFavorite = true
                #expect(sut.isFavorite == true)
                
                // 2. WHEN (Quand)
                // On exécute l'action.
                sut.toggleFavorite()
                
                // 3. THEN (Alors)
                // On vérifie qu'il est revenu à 'false'.
                #expect(sut.isFavorite == false)
        }
        
        //MARK: telechargement de l'image
        
        // Test 1 (Succès) : Que se passe-t-il si le téléchargement de l'image réussit ?
        // Test 2 (Échec) : Que se passe-t-il si le téléchargement échoue ?
        // Test 3 (Double Clic) : Que se passe-t-il si on clique deux fois (le "verrou" fonctionne-t-il)
        
        //MARK: Succes
        
        @Test
        @MainActor
        func testPrepareShareableImage_WhenSuccess_ShouldUpdateState() async {
                
                // 1. GIVEN (Étant donné)
                mockService.fetchProductsResult = .success
                // On vérifie que tout est à zéro
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
                
                // 2. WHEN (Quand)
                await sut.prepareShareableImage()
                
                // 3. THEN (Alors)
                // On vérifie que tout s'est bien passé
                #expect(sut.isPreparingShare == false) // Le spinner est arrêté (merci 'defer')
                #expect(sut.isShowingShareSheet == true) // La feuille doit s'ouvrir
                #expect(sut.imageToShare != nil) // L'image est chargée
                #expect(mockService.downloadImageCallCount == 1) // On a bien appelé le service 1x
        }
        
        //MARK: Echec
        @Test
        @MainActor
        func testPrepareShareableImage_WhenFailure_ShouldNotShowSheet() async {
                
                // 1. GIVEN
                mockService.downloadImageResult = .failure(CancellationError()) // On dit au mock d'échouer
                
                // 2. WHEN
                await sut.prepareShareableImage()
                
                // 3. THEN
                // On vérifie que l'état d'erreur est géré
                #expect(sut.isPreparingShare == false) // Le spinner est arrêté
                #expect(sut.isShowingShareSheet == false) // La feuille NE doit PAS s'ouvrir
                #expect(sut.imageToShare == nil) // Pas d'image
                #expect(mockService.downloadImageCallCount == 1) // On a quand même essayé de télécharger
        }
        
        //MARK: double clic
        @Test
        @MainActor
        func testPrepareShareableImage_WhenAlreadyPreparing_ShouldDoNothing() async {
                
                // 1. GIVEN (Étant donné)
                mockService.downloadImageResult  = .success // Le service va réussir (lentement)
                #expect(mockService.downloadImageCallCount == 0)
                
                // 2. WHEN (Quand)
                // On lance deux appels en "concurrence"
                // (sans s'attendre l'un l'autre)
                async let firstCall = sut.prepareShareableImage()
                async let secondCall = sut.prepareShareableImage()
                
                // On attend qu'ils soient tous les deux terminés
                let _ = await (firstCall, secondCall)
                
                // 3. THEN (Alors)
                // Le "guard !isPreparingShare" a dû fonctionner.
                // Le service ne doit avoir été appelé que 1 seule fois (par le premier appel).
                // Le deuxième appel a dû voir 'isPreparingShare == true' et s'arrêter net.
                #expect(mockService.downloadImageCallCount == 1)
                
                // Et l'état final doit être celui du succès (du premier appel)
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
        }
        
        struct UnknownTestError: Error { }
        
        @Test
        @MainActor
        func testPrepareShareableImage_WhenUnknownError_ShouldNotShowSheet() async {
                
                // 1. GIVEN
                // On dit au mock de lancer notre erreur inconnue
                mockService.downloadImageResult = .failure(UnknownTestError())
                
                // 2. WHEN
                await sut.prepareShareableImage()
                
                // 3. THEN
                #expect(sut.isPreparingShare == false)
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
        }
        
        // --- TEST DE LA FONCTION RESET ---
        @Test
        @MainActor
        func testResetShareableImage_WhenStateIsDirty_ShouldClearState() async {
                
                // 1. GIVEN (Étant donné)
                // On crée un état "sale" en simulant un partage réussi
                mockService.downloadImageResult = .success
                await sut.prepareShareableImage()
                
                // On vérifie que l'état est bien "sale"
                #expect(sut.isShowingShareSheet == true)
                #expect(sut.imageToShare != nil)
                
                // 2. WHEN (Quand)
                // On appelle la fonction de nettoyage
                sut.resetShareableImage()
                
                // 3. THEN (Alors)
                // On vérifie que tout a été remis à zéro
                #expect(sut.isShowingShareSheet == false)
                #expect(sut.imageToShare == nil)
        }
}

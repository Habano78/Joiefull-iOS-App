//
//  ProductListViewModelTests.swift
//  JoiefullTests
//
//  Created by Perez William on 03/11/2025.
//

import Testing
import SwiftUI
@testable import Joiefull

// La 'struct' qui contient nos tests
struct ProductListViewModelTests {
        
        var sut: ProductListViewModel
        var mockService: MockNetworkService
        
        @MainActor
        init() {
                // Le "setup" s'exécute avant chaque test
                mockService = MockNetworkService()
                sut = ProductListViewModel(service: mockService)
        }
        
        //MARK:  Happy path
        @Test
        @MainActor
        func testFetchProducts_WhenSuccess_ShouldUpdateStateToLoaded() async {
                
                // ___GIVEN
                mockService.fetchProductsResult = .success
                
                // ___WHEN
                await sut.reload()
                
                // ___THEN
                switch sut.state {
                case .loaded(let sections):
                        #expect(sections.count == 1)
                        #expect(sections.first?.category == "TEST")
                        #expect(sections.first?.products.first?.name == "Test Product")
                        #expect(sections.first?.products.first?.price == 50.0)
                default:
                        Issue.record("L'état final était \(sut.state), mais on attendait .loaded")
                }
        }
        
        //MARK: Unhappy Path
        @Test
        @MainActor
        func testFetchProducts_WhenFailure_ShouldUpdateStateToError() async {
                
                // GIVEN
                mockService.fetchProductsResult = .failure(NetworkError.serverError(statusCode: 500))
                
                // WHEN
                await sut.reload()
                
                // THEN
                switch sut.state {
                case .error(let message):
                        // On vérifie que le message est le bon
                        let expectedMessage = NetworkError.serverError(statusCode: 500).errorDescription
                        #expect(message == expectedMessage)
                default:
                        Issue.record("L'état final était \(sut.state), mais on attendait .error")
                }
        }
        
        // --- TEST 3 : L'ANNULATION ---
        @Test
        @MainActor
        func testFetchProducts_WhenCancellationError_ShouldUpdateStateToIdle() async {
                
                // 1. GIVEN (Étant donné)
                // On dit au mock de lancer une CancellationError
                mockService.fetchProductsResult = .failure(CancellationError())
                
                // 2. WHEN (Quand)
                await sut.reload()
                
                // 3. THEN (Alors)
                // On vérifie que l'état est bien revenu à '.idle'
                switch sut.state {
                case .idle:
                        // C'est ce qu'on veut ! Le test passe.
                        break
                default:
                        Issue.record("L'état final était \(sut.state), mais on attendait .idle")
                }
        }
        
        // --- TEST 4 : L'ERREUR INCONNUE ---
        
        // On a besoin d'une fausse erreur "inconnue"
        struct UnknownTestError: Error {} // Pas besoin de description
        
        @Test
        @MainActor
        func testFetchProducts_WhenUnknownError_ShouldUpdateStateToError() async {
                
                // 1. GIVEN
                let unknownError = UnknownTestError()
                mockService.fetchProductsResult = .failure(unknownError)
                
                // 2. WHEN
                await sut.reload()
                
                // 3. THEN
                // On vérifie que l'état est '.error'
                switch sut.state {
                case .error:
                        // C'est un succès ! L'état est bien '.error'.
                        // On n'a pas besoin de vérifier le message exact.
                        break // Le test passe
                default:
                        Issue.record("L'état final était \(sut.state), mais on attendait .error")
                }
        }
}

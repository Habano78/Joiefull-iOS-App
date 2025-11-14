//
//  ProductListViewModelTests.swift
//  JoiefullTests
//
//  Created by Perez William on 03/11/2025.
//

import Testing
import SwiftUI
@testable import Joiefull

struct ProductListViewModelTests {
        
        var sut: ProductListViewModel
        var mockService: MockNetworkService
        
        @MainActor
        init() {
                mockService = MockNetworkService()
                sut = ProductListViewModel(service: mockService)
        }
        
        //MARK: --- Tests FetchProducts ---
        
        @Test("Vérifie que l'état passe à .loaded en cas de succès réseau")
        @MainActor
        func testFetchProducts_WhenSuccess() async {
                
                // GIVEN
                mockService.fetchProductsResult = .success
                
                // WHEN
                await sut.reload()
                
                // THEN
                switch sut.state {
                case .loaded(let sections):
                        #expect(sections.count == 1)
                        #expect(sections.first?.category == "TEST")
                        #expect(sections.first?.products.first?.name == "Test Product")
                default:
                        Issue.record("État inattendu : \(sut.state), attendu : .loaded")
                }
        }
        
        @Test("Vérifie que l'état passe à .error en cas d'erreur réseau")
        @MainActor
        func testFetchProducts_WhenNetworkError() async {
                
                // GIVEN
                let networkError = NetworkError.serverError(statusCode: 500)
                mockService.fetchProductsResult = .failure(networkError)
                
                // WHEN
                await sut.reload()
                
                // THEN
                switch sut.state {
                case .error(let message):
                        #expect(message == networkError.errorDescription)
                default:
                        Issue.record("État inattendu : \(sut.state), attendu : .error")
                }
        }
        
        @Test("Vérifie que l'état revient à .idle en cas d'annulation")
        @MainActor
        func testFetchProducts_WhenCancellationError() async {
                
                // GIVEN
                mockService.fetchProductsResult = .failure(CancellationError())
                
                // WHEN
                await sut.reload()
                
                // THEN
                switch sut.state {
                case .idle:
                        break
                default:
                        Issue.record("État inattendu : \(sut.state), attendu : .idle")
                }
        }
        
        struct UnknownTestError: Error {}
        
        @Test("Vérifie que l'état passe à .error en cas d'erreur inconnue")
        @MainActor
        func testFetchProducts_WhenUnknownError() async {
                
                // GIVEN
                let unknownError = UnknownTestError()
                mockService.fetchProductsResult = .failure(unknownError)
                
                // WHEN
                await sut.reload()
                
                // THEN
                switch sut.state {
                case .error:
                        break
                default:
                        Issue.record("État inattendu : \(sut.state), attendu : .error")
                }
        }
            
            @Test("Vérifie que l'état .loading empêche les doubles appels")
            @MainActor
            func testFetchProducts_WhenAlreadyLoading_ShouldDoNothing() async {
                
                // 1. GIVEN (Étant donné)
                mockService.fetchProductsResult = .success
                #expect(mockService.fetchProductsCallCount == 0)

                // 2. WHEN (Quand)
                // On lance deux appels en parallèle
                async let firstCall = sut.reload()
                async let secondCall = sut.reload()
                
                // On attend qu'ils soient tous les deux terminés
                let _ = await (firstCall, secondCall)
                
                // 3. THEN (Alors)
                // Le 'guard' (if case .loading) a dû fonctionner.
                // Le service ne doit avoir été appelé QU'UNE SEULE FOIS.
                #expect(mockService.fetchProductsCallCount == 1)
                
                // L'état final doit être .loaded (du premier appel)
                switch sut.state {
                case .loaded:
                    break
                default:
                    Issue.record("État inattendu, le verrou a échoué")
                }
            }
}

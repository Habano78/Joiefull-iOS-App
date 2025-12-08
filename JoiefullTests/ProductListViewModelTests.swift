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
        
        //
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
        
        //
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
        
        //
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
        
        //
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
        
        //
        @Test("Vérifie que l'état .loading empêche les doubles appels")
        @MainActor
        func testFetchProducts_WhenAlreadyLoading_ShouldDoNothing() async {
                
                // 1. GIVEN
                mockService.fetchProductsResult = .success
                #expect(mockService.fetchProductsCallCount == 0)
                
                // 2. WHEN
                // On lance deux appels en parallèle
                async let firstCall = sut.reload()
                async let secondCall = sut.reload()
                
                let _ = await (firstCall, secondCall)
                
                // 3. THEN
                
                // Le service ne doit avoir été appelé QU'UNE SEULE FOIS... si le 'guard' (if case .loading) a fonctionné
                #expect(mockService.fetchProductsCallCount == 1)
                
                switch sut.state {
                case .loaded:
                        break
                default:
                        Issue.record("État inattendu, le verrou a échoué")
                }
        }
        
        
        @Test("Empêche de relancer le chargement si l'état est déjà .loading")
        @MainActor
        func testFetchProducts_WhenAlreadyLoading_ShouldReturnImmediately() async {
                // 1. GIVEN
                // setup()
                let mockService = MockNetworkService() // Utilisez un mock qui ne fait rien
                let sut = ProductListViewModel(service: mockService)
                
                // Mettez manuellement l'état à .loading
                sut.state = .loading
                
                // Assurez-vous que votre Mock a un compteur pour 'fetchProducts'
                // Pour cet exemple, supposons que votre Mock a un 'fetchProductsCallCount'
                mockService.fetchProductsCallCount = 0
                
                // 2. WHEN
                // Appeler fetchProducts (via reload) alors que l'état est .loading
                await sut.reload()
                
                // 3. THEN
                // Le service N'A PAS été appelé, et l'état est resté .loading
                #expect(mockService.fetchProductsCallCount == 0)
                #expect(sut.state == .loading)
        }
        
        // Défini une erreur non-NetworkError pour le test
        struct MockGenericError: Error {
                var localizedDescription: String {
                        return "Erreur de test générique non reconnue."
                }
        }
        
        @Test("Gère une erreur inconnue (non-NetworkError) et utilise localizedDescription")
        @MainActor
        func testFetchProducts_WhenUnknownErrorOccurs_ShouldSetErrorState() async throws {
                // 1. GIVEN
                // setup()
                let mockService = MockNetworkService()
                let sut = ProductListViewModel(service: mockService)
                
                // Configurez le mock pour lancer l'erreur générique
                mockService.fetchProductsResult = .failure(MockGenericError())
                
                // 2. WHEN
                await sut.reload()
                
                // 3. THEN
                // L'état doit être .error et contenir la localizedDescription de l'erreur générique
                #expect(mockService.fetchProductsCallCount == 1)
                
                if case .error(let message) = sut.state {
                        // 🛑 Modifiez l'assertion pour correspondre à la chaîne par défaut de Swift !
                        let expectedMessage = "L’opération n’a pas pu s’achever. (JoiefullTests.ProductListViewModelTests.MockGenericError erreur 1.)"
                        #expect(message == expectedMessage)
                } else {
                        #expect(false, "L'état attendu est .error mais est \(sut.state)")
                }
        }
}

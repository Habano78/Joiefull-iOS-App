//
//  ViewModel.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import Combine


@MainActor
class ProductListViewModel: ObservableObject {
        
        @Published var state: ProductListViewState = .idle
        
        //MARK: INJECTION DE DÉPENDANCE
        
        private let service: NetworkServiceProtocol
        
        init(service: NetworkServiceProtocol) {
                self.service = service
                
                Task {
                        await self.reload()
                }
        }
        
        //MARK: ACTION PRINCIPALE
        
        private func fetchProducts() async {
                
                if case .loading = state { 
                        return
                }
                
                self.state = .loading
                
                do {
                        let products = try await service.fetchProducts()
                        
                        // On vérifie que la tâche n'a pas été annulée
                        try Task.checkCancellation()
                        
                        // On met à jour l'état
                        self.state = .loaded(products)
                        
                } catch is CancellationError {
                        // Si la tâche est annulée (ex: l'utilisateur quitte la vue),on revient à l'état initial.
                        self.state = .idle
                } catch let error as NetworkError {
                        self.state = .error(error.errorDescription ?? "Une erreur est survenue")
                } catch {
                        self.state = .error(error.localizedDescription)
                }
        }
        
        // C'est la seule fonction que la Vue appellera.
        func reload() async {
                await fetchProducts()
        }
}

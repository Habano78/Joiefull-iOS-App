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
        }
        
        //MARK: METHODES
        
        private func fetchProducts() async {
                
                if case .loading = state {
                        return
                }
                
                self.state = .loading
                
                do {
                        // 1. On récupère la liste plate (ne change pas)
                        let products = try await service.fetchProducts()
                        try Task.checkCancellation()
                        
                        
                        // un Dictionnaire pour grouper tous les produits par catégorie.
                        let groupedProducts = Dictionary(grouping: products, by: { $0.category })
                        
                        // On transforme ce dictionnaire en notre array de [ProductSection]
                        let sections = groupedProducts.map { (category, products) in
                                ProductSection(category: category, products: products)
                        }.sorted(by: { $0.category < $1.category })
                        
                        // On envoie les SECTIONS à la vue
                        self.state = .loaded(sections)
                        
                } catch is CancellationError {
                        self.state = .idle /// Si la tâche est annulée (ex: l'utilisateur quitte la vue),on revient à l'état initial.
                        
                } catch let error as NetworkError {
                        self.state = .error(error.errorDescription ?? "Une erreur est survenue")
                        
                } catch {
                        self.state = .error(error.localizedDescription)
                }
        }
        
        func reload() async {
                await fetchProducts()
        }
}

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
        
        //MARK: Properties
        
        @Published var state: ProductListViewState = .idle
        private let service: NetworkServiceProtocol
        
        //MARK: VM State
        enum ProductListViewState {
                case idle
                case loading
                case loaded([ProductSection])
                case error(String)
        }
        
        
        // MARK: Init
        init(service: NetworkServiceProtocol) {
                self.service = service
        }
        
        //MARK: Methodes
        private func fetchProducts() async {
                
                if case .loading = state {
                        return
                }
                
                self.state = .loading
                
                do {
                        let products = try await service.fetchProducts()
                        try Task.checkCancellation()
                        
                        let groupedProducts = Dictionary(grouping: products, by: { $0.category })
                        
                        let sections = groupedProducts.map { (category, products) in
                                ProductSection(category: category, products: products)
                        }.sorted(by: { $0.category < $1.category })
                        
                        self.state = .loaded(sections)
                        
                } catch is CancellationError {
                        self.state = .idle /// Si la tâche est annulée (ex: l'utilisateur quitte la vue),on revient à l'état initial.
                        
                } catch let error as NetworkError {
                        let fallbackError = NSLocalizedString("ERROR_DEFAULT_FALLBACK", comment: "Une erreur est survenue")
                        self.state = .error(error.errorDescription ?? fallbackError)
                        
                } catch {
                        self.state = .error(error.localizedDescription)
                }
        }
        
        func reload() async {
                await fetchProducts()
        }
        
}

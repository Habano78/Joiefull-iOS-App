//
//  ViewModel.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
        
        
        @Published var product: Product
        private let service: NetworkServiceProtocol
        
        // Sheet
        @Published var isShowingShareSheet = false /// Trigger de Sheet
        @Published private(set) var imageToShare: UIImage? ///Image télécharhgée pour la view
        @Published private(set) var isPreparingShare = false
        
        // Avis
        @Published var userRating: Int = 0
        @Published var userComment: String = ""
        
        // Favoris
        @Published var isFavorite: Bool = false // est-ce que l'utilisateur à cliqué ?
        
        
        //MARK: Init
        init(product: Product, service: NetworkServiceProtocol) {
                self.product = product
                self.service = service
        }
        
        //MARK: Methodes
        
        // Favoris : appelée quand on clique sur le coeur
        func toggleFavorite () {
                isFavorite.toggle()
                
                if isFavorite {
                        
                }
        }
        
        
        // Download + Prepare
        func prepareShareableImage() async {
                
                // pour éviter le double-clic
                guard !isPreparingShare else { return }
                
                isPreparingShare = true
                defer { isPreparingShare = false }
                
                do {
                        // téléchargement de l'image
                        let image = try await service.downloadImage(
                                from: product.picture.url
                        )
                        
                        // si la vue a disparu, on annule la tâche ici
                        try Task.checkCancellation()
                        
                        // on n'arrive ici que si la tâche est toujours active
                        imageToShare = image
                        isShowingShareSheet = true
                        
                } catch is CancellationError { /// annulation cancellée
                        
                } catch let error as NetworkError {
                        print("Erreur de téléchargement d'image: \(error.errorDescription ?? "")")
                        imageToShare = nil
                } catch {
                        print("Erreur inconnue: \(error.localizedDescription)")
                        imageToShare = nil
                }
        }
        
        // MARK: - Reset
        func resetShareableImage() {
                imageToShare = nil
                isShowingShareSheet = false
        }
}

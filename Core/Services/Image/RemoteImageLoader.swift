//
//  RemoteImageLoader.swift
//  Joiefull
//
//  Created by Perez William on 19/11/2025.
//

import SwiftUI
import Combine

@MainActor
class RemoteImageLoader: ObservableObject {
        
        @Published var image: UIImage?
        @Published var isLoading = false
        @Published var error: Error?
        
        private let urlString: String
        private let service: NetworkServiceProtocol
        
        init(urlString: String, service: NetworkServiceProtocol) {
                self.urlString = urlString
                self.service = service
        }
        
        func load() async {
                guard !isLoading else { return }
                isLoading = true
                error = nil
                
                do {
                        let img = try await service.downloadImage(from: urlString)
                        self.image = img
                } catch {
                        self.error = error
                }
                
                isLoading = false
        }
}

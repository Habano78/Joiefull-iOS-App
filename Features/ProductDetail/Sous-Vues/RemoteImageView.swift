//
//  SwiftUIView.swift
//  Joiefull
//
//  Created by Perez William on 19/11/2025.
//

import SwiftUI
import UIKit

struct RemoteImageView: View {
        
        let url: String
        let service: NetworkServiceProtocol
        
        @State private var uiImage: UIImage?
        @State private var isLoading = false
        @State private var hasError = false
        
        var body: some View {
                ZStack {
                        if let uiImage {
                                Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                        }
                        else if isLoading {
                                ZStack {
                                        Color.gray.opacity(0.2)
                                        ProgressView()
                                }
                        }
                        else if hasError {
                                Color.gray.opacity(0.2) // Erreur
                                
                        }
                        else {
                                Color.gray.opacity(0.1) // État "initial"
                        }
                }
                .clipped()
                .task {
                        await loadImage()
                }
        }
}

private extension RemoteImageView {
        
        func loadImage() async {
                // Si on a déjà une image → pas besoin de re-télécharger
                guard uiImage == nil else { return }
                
                isLoading = true
                hasError = false
                
                do {
                        let image = try await service.downloadImage(from: url)
                        uiImage = image
                } catch {
                        hasError = true
                }
                
                isLoading = false
        }
}

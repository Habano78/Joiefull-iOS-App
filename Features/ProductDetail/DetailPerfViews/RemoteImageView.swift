//
//  RemoteImageView.swift
//  Joiefull
//
//  Created by Perez William on 19/11/2025.
//

import SwiftUI
import UIKit

struct RemoteImageView: View {
        
        // MARK: Public API
       @EnvironmentObject var diContainer: AppDIContainer
        let url: String
       /// Del. let service: NetworkServiceProtocol
        let contentMode: ContentMode
        
        // MARK: Internal
        
        @State private var uiImage: UIImage?
        @State private var isLoading = false
        @State private var hasError = false
        
        // MARK: Init
        
        init(
                url: String,
                contentMode: ContentMode = .fill
        ) {
                self.url = url
                self.contentMode = contentMode
        }
        
        // MARK: Body
        
        var body: some View {
                ZStack {
                        if let uiImage {
                                Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: contentMode)   // .fill ou .fit
                                        .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                                
                        } else if isLoading {
                                Color.gray.opacity(0.1)
                                ProgressView()
                                
                        } else if hasError {
                                Color.gray.opacity(0.2)
                                
                        } else {
                                Color.gray.opacity(0.1)
                        }
                }
                .clipped()
                .task {
                        await loadImage()
                }
        }
}

// MARK: Chargement de l'image

private extension RemoteImageView {
        
        func loadImage() async {
                
                guard uiImage == nil else { return }
                
                isLoading = true
                hasError = false
                
                do {
                        let image = try await diContainer.networkService.downloadImage(from: url)
                        uiImage = image
                } catch {
                        hasError = true
                }
                
                isLoading = false
        }
}

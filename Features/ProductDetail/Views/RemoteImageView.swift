//
//  RemoteImageView.swift
//  Joiefull
//
//  Created by Perez William on 19/11/2025.
//

//
//  RemoteImageView.swift
//  Joiefull
//
//  Created by William on 19/11/2025.
//

import SwiftUI
import UIKit

struct RemoteImageView: View {
    
    // MARK: - Public API
    
    let url: String
    let service: NetworkServiceProtocol
    let contentMode: ContentMode   // .fill / .fit
    
    // MARK: - Internal State
    
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    
    // MARK: - Init
    
    /// `contentMode` a une valeur par défaut (.fill) pour garder un appel simple :
    /// RemoteImageView(url: ..., service: ...)
    init(
        url: String,
        service: NetworkServiceProtocol,
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.service = service
        self.contentMode = contentMode
    }
    
    // MARK: - Body
    
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
        .clipped()     // coupe ce qui dépasse du cadre parent
        .task {
            await loadImage()
        }
    }
}

// MARK: - Chargement de l'image

private extension RemoteImageView {
    
    func loadImage() async {
        // Si l'image est déjà chargée, ne pas relancer un download
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

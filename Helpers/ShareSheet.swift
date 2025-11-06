//
//  ShareSheet.swift
//  Joiefull
//
//  Created by Perez William on 05/11/2025.
//

import SwiftUI
import LinkPresentation

class ImageShareProvider: NSObject, UIActivityItemSource {
    
    let image: UIImage
    let message: String
    
    init(image: UIImage, message: String) {
        self.image = image
        self.message = message
        super.init()
    }
    
    // 1. Ce que la feuille de partage doit afficher (un placeholder)
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    // 2. L'objet réel à partager
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // On retourne l'image pour la plupart des activités
        return image
    }
    
    // 3. Le "contexte" (le texte) qui va AVEC l'image
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        // On met notre 'message' comme titre
        metadata.title = message
        
        // On dit à iOS que c'est une image
        metadata.imageProvider = NSItemProvider(object: image)
        
        return metadata
    }
}

struct ShareSheet: UIViewControllerRepresentable {
        var items: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


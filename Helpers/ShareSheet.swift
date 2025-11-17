//
//  ShareSheet.swift
//  Joiefull
//
//  Created by Perez William on 05/11/2025.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
        
        let items: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
                let controller = UIActivityViewController(
                        activityItems: items,
                        applicationActivities: nil
                )
                return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
                // Rien
        }
}

//NOTE: // Le composant natif SwiftUI ShareLink est insuffisant pour gérer le partage au même temps image et texte. ShareSheet est le pont vers UIKit. Le ViewModel lui donne les objets finaux (UIImage et String).

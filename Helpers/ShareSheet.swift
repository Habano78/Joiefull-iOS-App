//
//  ShareSheet.swift
//  Joiefull
//
//  Created by Perez William on 05/11/2025.
//

import SwiftUI
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
        var items: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


//
//  JoiefullApp.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import SwiftUI

@main
struct JoiefullApp: App {
    
    @StateObject private var diContainer = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            // --- CORRECTION ---
            // 1. On fabrique le ViewModel ici, en utilisant l'usine
            let viewModel = diContainer.makeProductListViewModel()
            
            // 2. On le donne à la vue.
            ProductListView(viewModel: viewModel)
            
            // 3. On injecte quand même le conteneur
            //    pour les futures vues (ex: l'écran de détail)
                .environmentObject(diContainer)
        }
    }
}

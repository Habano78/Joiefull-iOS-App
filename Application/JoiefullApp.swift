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
                        // On fabrique le ViewModel utilisant l'usine
                        let viewModel = diContainer.makeProductListViewModel()
                        
                        // On injecte le VM dans la vue.
                        ProductListView(viewModel: viewModel)
                        
                        //On injecte le conteneur pour les futures vues (ex: l'écran de détail)
                                .environmentObject(diContainer)
                }
        }
}

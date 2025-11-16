//
//  JoiefullApp.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import SwiftUI

@main
struct JoiefullApp: App {
        
        @StateObject private var diContainer = AppDIContainer() ///l'usine central (Singleton)
        
        var body: some Scene {
                WindowGroup {
                        let viewModel = diContainer.makeProductListViewModel()
                        ProductListView(viewModel: viewModel) /// On injecte le VM dans la vue.
                                .environmentObject(diContainer) ///On injecte le conteneur pour les futures vues (ex: l'écran de détail)/
                                .preferredColorScheme(.light)
                }
        }
}

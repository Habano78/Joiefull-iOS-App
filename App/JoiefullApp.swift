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
                        let viewModel = diContainer.makeProductListViewModel()
                        ProductListView(viewModel: viewModel) /// injecter le VM dans la vue.
                                .environmentObject(diContainer) ///conteneur accèsible à d'autres vues (ex: l'écran de détail)
                                .preferredColorScheme(.light)
                }
        }
}

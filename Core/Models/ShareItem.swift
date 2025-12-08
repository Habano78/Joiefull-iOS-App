//
//  ShareItem.swift
//  Joiefull
//
//  Created by Perez William on 03/12/2025.
//

import Foundation
import SwiftUI


// Structure pour identifier ce qu'on partage
struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
    let message: String
}

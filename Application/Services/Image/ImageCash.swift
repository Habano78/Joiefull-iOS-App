//
//  ImageCash.swift
//  Joiefull
//
//  Created by Perez William on 18/11/2025.
//

import UIKit

actor ImageCache {
    
    static let shared = ImageCache()
    
    private var storage: [URL: UIImage] = [:]
    
    func image(for url: URL) -> UIImage? {
        return storage[url]
    }
    
    func insert(_ image: UIImage, for url: URL) {
        storage[url] = image
    }
}

//Pourquoi "actor" ?
///Parce que le cache sera lu/écrit depuis des tâches async concurrentes
///actor garantit l’accès thread-safe sans que tu aies à gérer des locks.

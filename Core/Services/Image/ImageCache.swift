//
//  ImageCache.swift
//  Joiefull
//
//  Created by Perez William on 26/11/2025.
//

import UIKit

/// Cache global pour les images - RAM (NSCache) - Disque (fichiers dans Caches/ImageCache)
final class ImageCache {
        
        static let shared = ImageCache()
        
        private let memoryCache = NSCache<NSString, UIImage>()
        private let fileManager = FileManager.default
        private let diskDirectoryURL: URL
        
        private init() {
                // Dossier .../Library/Caches/ImageCache
                let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
                diskDirectoryURL = cachesURL.appendingPathComponent("ImageCache", isDirectory: true)
                
                // On essaie de créer le dossier si besoin (on ignore l’erreur si déjà présent)
                try? fileManager.createDirectory(at: diskDirectoryURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        }
        
        // MARK: - Public
        
        /// Cherche d’abord en RAM, puis sur disque.
        func image(forKey key: String) -> UIImage? {
                let nsKey = NSString(string: key)
                
                // 1) RAM
                if let image = memoryCache.object(forKey: nsKey) {
                        return image
                }
                
                // 2) Disque
                let diskURL = urlForDiskKey(key)
                if let data = try? Data(contentsOf: diskURL),
                   let image = UIImage(data: data) {
                        // on remet l’image en RAM pour la prochaine fois
                        memoryCache.setObject(image, forKey: nsKey)
                        return image
                }
                
                return nil
        }
        
        /// Sauvegarde en RAM + disque.
        func save(_ image: UIImage, forKey key: String) {
                let nsKey = NSString(string: key)
                
                // RAM
                memoryCache.setObject(image, forKey: nsKey)
                
                // Disque (JPEG 90%)
                let diskURL = urlForDiskKey(key)
                guard let data = image.jpegData(compressionQuality: 0.9) else { return }
                
                do {
                        try data.write(to: diskURL, options: .atomic)
                } catch {
                        // Ici on log juste, mais on n’empêche pas l’affichage
                        let format = NSLocalizedString("LOG_DISK_WRITE_FAILURE", comment: "Impossible d’écrire l’image sur disque")
                        print(String(format: format, error.localizedDescription))
                        
                }
        }
        
        // MARK: - Helpers
        
        private func urlForDiskKey(_ key: String) -> URL {
                // On nettoie un peu la clé pour en faire un nom de fichier safe
                let fileName = key
                        .replacingOccurrences(of: "/", with: "_")
                        .replacingOccurrences(of: ":", with: "_")
                
                return diskDirectoryURL
                        .appendingPathComponent(fileName)
                        .appendingPathExtension("jpg")
        }
}

//
//  Service.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import SwiftUI

protocol NetworkServiceProtocol {
        func fetchProducts() async throws -> [Product]
        func downloadImage(from urlString: String) async throws -> UIImage
}

class NetworkService: NetworkServiceProtocol {
        
        private let apiURL = "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/api/clothes.json"
        
        func fetchProducts() async throws -> [Product] {
                do {
                        guard let url = URL(string: apiURL) else { throw NetworkError.invalidURL }
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
                        }
                        
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        return try decoder.decode([Product].self, from: data)
                        
                } catch let error as DecodingError { throw NetworkError.decodingError(error)
                } catch let error as URLError { throw NetworkError.networkError(error)
                } catch let error as NetworkError { throw error
                } catch { throw NetworkError.unknownError(error) }
        }
        
        
        func downloadImage(from urlString: String) async throws -> UIImage {
                
                ///  vérifie le cache RAM + disque d'abord
                if let cached = ImageCache.shared.image(forKey: urlString) {
                        return cached
                }
                
                /// Construire l'URL
                guard let url = URL(string: urlString) else {
                        throw NetworkError.invalidURL
                }
                
                do {
                        /// Appel réseau
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        /// Vérification HTTP
                        if let http = response as? HTTPURLResponse,
                           !(200..<300).contains(http.statusCode) {
                                throw NetworkError.serverError(statusCode: http.statusCode)
                        }
                        
                        /// Décodage de l'image
                        guard let image = UIImage(data: data) else {
                                /// UIImage(data:) ne renvoie pas d’erreur, on en fabrique une
                                let localError = NSError(
                                        domain: "ImageDecoding",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("ERROR_IMAGE_DECODING", comment: "Impossible de décoder l'image")]
                                )
                                throw NetworkError.unknownError(localError)
                        }
                        
                        ///Sauvegarde dans le cache (RAM + disque)
                        ImageCache.shared.save(image, forKey: urlString)
                        
                        return image
                        
                } catch let urlError as URLError {
                        
                        throw NetworkError.networkError(urlError)
                        
                } catch let decodingError as DecodingError {
                        
                        throw NetworkError.decodingError(decodingError)
                        
                } catch {
                        
                        throw NetworkError.unknownError(error)
                }
        }
        
        
        
        
}

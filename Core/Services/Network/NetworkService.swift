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
                do {
                        guard let url = URL(string: urlString) else {
                                throw NetworkError.invalidURL
                        }
                        
                        // Image dans le cache ?
                        if let cached = await ImageCache.shared.image(for: url) {
                                return cached
                        }
                        
                        // 2) Sinon, on télécharge
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                                throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
                        }
                        
                        guard let image = UIImage(data: data) else {
                                throw NetworkError.decodingError(.dataCorrupted(.init(
                                        codingPath: [],
                                        debugDescription: "Image invalide"
                                )))
                        }
                        
                        // 3) On met dans le cache
                        await ImageCache.shared.insert(image, for: url)
                        
                        return image
                        
                } catch let error as URLError {
                        throw NetworkError.networkError(error)
                } catch let error as NetworkError {
                        throw error
                } catch {
                        throw NetworkError.unknownError(error)
                }
        }
        
}

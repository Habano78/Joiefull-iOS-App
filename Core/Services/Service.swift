//
//  Service.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation
import SwiftUI

//MARK: -- PROTOCOLE

protocol NetworkServiceProtocol {
        func fetchProducts() async throws -> [Product]
        func downloadImage(from urlString: String) async throws -> UIImage
}


//MARK: -- IMPLÉMENTATION

class NetworkService: NetworkServiceProtocol {
        
        private let apiURL = "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/api/clothes.json"
        
        func fetchProducts() async throws -> [Product] {
                
                do {
                        
                        guard let url = URL(string: apiURL) else {
                                throw NetworkError.invalidURL
                        }
                        
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                                throw NetworkError.serverError(statusCode: statusCode)
                        }
                        
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        let products = try decoder.decode([Product].self, from: data)
                        return products
                        
                } catch let error as DecodingError {
                        print(NetworkError.decodingError(error).errorDescription ?? "Erreur décodage")
                        throw NetworkError.decodingError(error)
                        
                } catch let error as URLError {
                        print(NetworkError.networkError(error).errorDescription ?? "Erreur réseau")
                        throw NetworkError.networkError(error)
                        
                } catch let error as NetworkError {
                        print(error.errorDescription ?? "Erreur réseau custom")
                        throw error
                        
                } catch {
                        print(NetworkError.unknownError(error).errorDescription ?? "Erreur inconnue")
                        throw NetworkError.unknownError(error)
                }
        }
        
        //MARK: ___ Telechargement de l'image
        
        func downloadImage(from urlString: String) async throws -> UIImage {
                // 1. On utilise le même 'guard' que pour le fetch
                guard let url = URL(string: urlString) else { // ????? url arriba : mismo ? même guard ???
                        throw NetworkError.invalidURL
                }
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                        throw NetworkError.serverError(statusCode: statusCode)
                }
                
                if let image = UIImage(data: data) {
                        return image
                } else {
                        throw NetworkError.decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid image data")))
                }
        }
        
}


//  NOTE : toute la complexité de la gestion d'erreurs est centralisée à l'intérieur du NetworkService. Séparation des Préoccupations!

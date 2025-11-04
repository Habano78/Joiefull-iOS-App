//
//  Service.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation

//MARK: -- PROTOCOLE

protocol NetworkServiceProtocol {
        func fetchProducts() async throws -> [Product]
}


//MARK: -- IMPLÉMENTATION

class NetworkService: NetworkServiceProtocol {
        
        private let apiURL = "https://raw.githubusercontent.com/OpenClassrooms-Student-Center/Cr-ez-une-interface-dynamique-et-accessible-avec-SwiftUI/main/api/clothes.json"
        
        func fetchProducts() async throws -> [Product] {
                
                do {
                        
                        // 1. GESTION ERREUR CLIENT
                        guard let url = URL(string: apiURL) else {
                                throw NetworkError.invalidURL
                        }
                        
                        // 2. APPEL RÉSEAU
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        // 3. GESTION ERREUR SERVEUR
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                                throw NetworkError.serverError(statusCode: statusCode)
                        }
                        
                        // 4. GESTION ERREUR DÉCODAGE
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        let products = try decoder.decode([Product].self, from: data)
                        return products
                        
                } catch let error as DecodingError {
                        // Si c'est une erreur de décodage
                        print(NetworkError.decodingError(error).errorDescription ?? "Erreur décodage")
                        throw NetworkError.decodingError(error)
                        
                } catch let error as URLError {
                        // Si c'est une erreur réseau (pas de connexion, timeout...)
                        print(NetworkError.networkError(error).errorDescription ?? "Erreur réseau")
                        throw NetworkError.networkError(error)
                        
                } catch let error as NetworkError {
                        // Si c'est une de nos erreurs qu'on a déjà lancée (invalidURL, serverError)
                        print(error.errorDescription ?? "Erreur réseau custom")
                        throw error
                        
                } catch {
                        // Toutes les autres erreurs inconnues
                        print(NetworkError.unknownError(error).errorDescription ?? "Erreur inconnue")
                        throw NetworkError.unknownError(error)
                }
        }
}


//  NOTE : toute la complexité de la gestion d'erreurs est centralisée à l'intérieur du NetworkService. Séparation des Préoccupations!

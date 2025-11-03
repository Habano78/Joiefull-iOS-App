//
//  ErrorsService.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation

//MARK: --- Errors personalisés

enum NetworkError: Error, LocalizedError { ///LocalizedError permet d'avoir des messages d'erreur.
        case invalidURL
        case serverError(statusCode: Int)
        case networkError(URLError)
        case decodingError(DecodingError)
        case unknownError(Error) /// erreur général au cas où
        
        // Pour afficher les messages dans la console
        var errorDescription: String? {
                switch self {
                case .invalidURL:
                        return "❌ L'URL de l'API est invalide."
                case .serverError(let code):
                        return "❌ Erreur du serveur. Code: \(code)."
                case .networkError(let urlError):
                        return "❌ Erreur réseau. L'utilisateur n'est peut-être pas connecté. \(urlError.localizedDescription)"
                case .decodingError(let decError):
                        // C'est super utile pour déboguer le JSON !
                        return "❌ Erreur de décodage. Le modèle ne correspond pas au JSON. \(decError.localizedDescription)"
                case .unknownError(let err):
                        return "❌ Erreur inconnue. \(err.localizedDescription)"
                }
        }
}

//
//  NetworkError.swift
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
        
        /// Pour afficher les messages dans la console
        var errorDescription: String? {
                switch self {
                        
                case .invalidURL:
                        return "\(NSLocalizedString("ERROR_INVALID_URL", comment: "Erreur URL non valide"))"
                        
                case .serverError(let code):
                        let format = NSLocalizedString("ERROR_SERVER_FORMAT", comment: "Erreur serveur avec code")
                        return String(format: "%@", format, code)
                        
                case .networkError(let urlError):
                        let format = NSLocalizedString("ERROR_NETWORK_FORMAT", comment: "Erreur réseau avec description")
                        return String(format: "%@", format, urlError.localizedDescription)
                        
                case .decodingError(let decError):
                        let format = NSLocalizedString("ERROR_DECODING_FORMAT", comment: "Erreur de décodage avec description")
                        return String(format: "%@", format, decError.localizedDescription)
                        
                case .unknownError(let err):
                        let format = NSLocalizedString("ERROR_UNKNOWN_FORMAT", comment: "Erreur inconnue avec description")
                        return String(format: "%@", format, err.localizedDescription)
                }
        }
}

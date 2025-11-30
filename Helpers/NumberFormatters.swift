//
//  NumberFormatters.swift
//  Joiefull
//
//  Created by Perez William on 27/11/2025.
//

import Foundation

// MARK: Pour gérer la devise

extension NumberFormatter {
        /// Fournit un NumberFormatter configuré pour afficher la devise en EUR selon la localité de l'utilisateur.
        static var localizedCurrencyFormatter: NumberFormatter {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencyCode = "EUR"
                formatter.maximumFractionDigits = 2
                formatter.locale = Locale.current /// adapte le format (virgule/point) à la région
                return formatter
        }
}

// MARK: Pour l'Accessibilité Prix

struct AccessibilityPriceHelper {
        
        static func generateA11yPriceDescription(
                currentPrice: Double,
                originalPrice: Double
        ) -> String {
                
                let formatter = NumberFormatter.localizedCurrencyFormatter
                
                /// Formater les prix avec le NumberFormatter
                let currentPriceString = formatter.string(from: NSNumber(value: currentPrice)) ?? "\(currentPrice)"
                let originalPriceString = formatter.string(from: NSNumber(value: originalPrice)) ?? "\(originalPrice)"
                
                /// Récupérer les formats de phrases localisées (via NSLocalizedString)
                let fullFormat = NSLocalizedString("A11Y_PRICE_FULL_FORMAT", comment: "")
                let normalFormat = NSLocalizedString("A11Y_PRICE_NORMAL_FORMAT", comment: "")
                
                if originalPrice > currentPrice {
                        /// Utiliser le format complet (avec réduction)
                        return String(format: fullFormat, currentPriceString, originalPriceString)
                } else {
                        /// Utiliser le format normal (sans réduction)
                        return String(format: normalFormat, currentPriceString)
                }
        }
}

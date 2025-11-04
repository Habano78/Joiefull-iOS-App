//
//  ProductListViewState.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation


enum ProductListViewState {
        case idle
        case loading
        case loaded([ProductSection])
        case error(String)
}

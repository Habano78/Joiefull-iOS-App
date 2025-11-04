//
//  ProductListViewState.swift
//  Joiefull
//
//  Created by Perez William on 03/11/2025.
//

import Foundation


// public pour que le ViewModel et la Vue puissent le voir.
enum ProductListViewState {
        case idle
        case loading
        case loaded([Product])
        case error(String)
}

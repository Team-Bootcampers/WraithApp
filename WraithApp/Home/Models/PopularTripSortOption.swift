//
//  PopularTripSortOption.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum PopularTripSortOption: CaseIterable {
    case popularity
    case price
    case rating

    var title: String {
        switch self {
        case .popularity: return "Popülerlik"
        case .price: return "Fiyat"
        case .rating: return "Puan"
        }
    }
}

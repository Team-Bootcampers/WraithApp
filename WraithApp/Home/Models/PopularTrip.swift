//
//  PopularTrip.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct PopularTrip {
    let id: String
    let title: String
    let imageURL: URL?
    let rating: Double
    let reviewCount: Int
    let description: String
    let price: Int
    let currency: String
    let popularityScore: Int
    var isFavorite: Bool
}

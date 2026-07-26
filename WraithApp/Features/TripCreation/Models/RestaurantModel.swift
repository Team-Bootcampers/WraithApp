//
//  RestaurantModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct Restaurant: Equatable, Codable {
    let id: String
    let name: String
    let rating: Double
    let averagePricePerPerson: Int
    let currency: String
    let imageURL: URL?
    let address: String
}

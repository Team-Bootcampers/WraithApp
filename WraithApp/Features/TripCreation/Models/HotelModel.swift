//
//  HotelModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct Hotel: Equatable, Codable {
    let id: String
    let name: String
    let rating: Double
    let pricePerNight: Int
    let currency: String
    let imageURL: URL?
}

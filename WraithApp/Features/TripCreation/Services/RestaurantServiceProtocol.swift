//
//  RestaurantServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

protocol RestaurantServiceProtocol {
    func fetchRestaurants(country: String, city: String, personalityAnalysis: String) async throws -> [Restaurant]
}

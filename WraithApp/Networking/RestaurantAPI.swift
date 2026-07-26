//
//  RestaurantAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct RestaurantPriceDto: Decodable {
    let amount: Double
    let currency: String
    let period: String
}

struct RestaurantDto: Decodable {
    let id: String
    let name: String
    let rating: Double
    let address: String
    let price: RestaurantPriceDto
    let images: [String]
    let country: String
    let cityName: String
}

/// Wraps `/restaurants` from the CoreBackendKit API — takes a country, city, and the
/// traveler's `/ai/travel-personality` write-up, and returns restaurants picked to suit them.
enum RestaurantAPI {

    static func fetchRestaurants(country: String, city: String, personalityAnalysis: String, token: String?) async throws -> [RestaurantDto] {
        var components = URLComponents()
        components.path = "/restaurants"
        components.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "personalityAnalysis", value: personalityAnalysis)
        ]
        guard let path = components.string else { throw APIError.invalidURL }

        print("➡️ GET https://wraithathon.gokhansal.com\(path)")
        print("➡️ Authorization: \(token.map { "Bearer \($0.prefix(12))…" } ?? "(none)")")
        print("➡️ country=\(country) city=\(city)")
        print("➡️ personalityAnalysis (\(personalityAnalysis.count) chars): \(personalityAnalysis)")

        return try await APIClient.shared.request(path: path, method: "GET", authToken: token)
    }

    static func fetchRestaurant(id: String, token: String?) async throws -> RestaurantDto {
        try await APIClient.shared.request(path: "/restaurants/\(id)", method: "GET", authToken: token)
    }
}

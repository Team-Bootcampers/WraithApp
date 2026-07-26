//
//  RestaurantService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Backs `RestaurantServiceProtocol` with the real `/restaurants` endpoint.
final class RestaurantService: RestaurantServiceProtocol {

    func fetchRestaurants(country: String, city: String, personalityAnalysis: String) async throws -> [Restaurant] {
        let dtos = try await RestaurantAPI.fetchRestaurants(
            country: Self.backendCountryName(for: country),
            city: city,
            personalityAnalysis: personalityAnalysis,
            token: UserSession.shared.idToken
        )
        return dtos.map(Self.makeRestaurant)
    }

    /// `Country.name` comes from countriesnow.space in English (e.g. "Turkey"), but `/restaurants`
    /// matches by the Turkish country name and 500s on the English form.
    private static func backendCountryName(for country: String) -> String {
        country == "Turkey" ? "Türkiye" : country
    }

    private static func makeRestaurant(from dto: RestaurantDto) -> Restaurant {
        Restaurant(
            id: dto.id,
            name: dto.name,
            rating: dto.rating,
            averagePricePerPerson: Int(dto.price.amount.rounded()),
            currency: dto.price.currency,
            imageURL: dto.images.first.flatMap(URL.init(string:)),
            address: dto.address
        )
    }
}

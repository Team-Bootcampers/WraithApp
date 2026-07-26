//
//  MockRestaurantService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class MockRestaurantService: RestaurantServiceProtocol {

    private static let nameSuffixes = ["Sofra Restoran", "Balık Evi", "Köfteci Ali", "Deniz Manzara", "Lezzet Durağı"]
    private static let ratings = [4.4, 4.7, 4.2, 4.5, 3.9]
    private static let averagePrices = [350, 600, 250, 500, 300]

    func fetchRestaurants(country: String, city: String, personalityAnalysis: String) async throws -> [Restaurant] {
        try await Task.sleep(nanoseconds: 500_000_000)

        let citySlug = city.folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: " ", with: "")

        return Self.nameSuffixes.indices.map { index in
            Restaurant(
                id: "\(citySlug)-restaurant-\(index)",
                name: "\(city) \(Self.nameSuffixes[index])",
                rating: Self.ratings[index],
                averagePricePerPerson: Self.averagePrices[index],
                currency: "TL",
                imageURL: URL(string: "https://picsum.photos/seed/\(citySlug)restaurant\(index)/300/200")
            )
        }
    }
}

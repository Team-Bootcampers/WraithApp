//
//  MockHotelService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class MockHotelService: HotelServiceProtocol {

    private static let nameSuffixes = ["Palace Hotel", "Resort & Spa", "City Suites", "Grand Inn", "Boutique Hotel"]
    private static let ratings = [4.5, 4.2, 3.9, 4.7, 4.0]
    private static let prices = [1450, 980, 750, 2200, 1650]

    func fetchHotels(city: String) async throws -> [Hotel] {
        try await Task.sleep(nanoseconds: 500_000_000)

        let citySlug = city.folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: " ", with: "")

        return Self.nameSuffixes.indices.map { index in
            Hotel(
                id: "\(citySlug)-\(index)",
                name: "\(city) \(Self.nameSuffixes[index])",
                rating: Self.ratings[index],
                pricePerNight: Self.prices[index],
                currency: "TL",
                imageURL: URL(string: "https://picsum.photos/seed/\(citySlug)\(index)/300/200")
            )
        }
    }
}

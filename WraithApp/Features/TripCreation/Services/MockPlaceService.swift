//
//  MockPlaceService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class MockPlaceService: PlaceServiceProtocol {

    private static let nameSuffixes = ["Tarihi Çarşı", "Ulu Cami", "Şehir Müzesi", "Sahil Parkı", "Kale Manzara Noktası"]
    private static let ratings = [4.6, 4.3, 4.8, 4.1, 4.4]
    private static let entryFees = [0, 0, 120, 0, 30]

    func fetchPlaces(city: String) async throws -> [Place] {
        try await Task.sleep(nanoseconds: 500_000_000)

        let citySlug = city.folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: " ", with: "")

        return Self.nameSuffixes.indices.map { index in
            Place(
                id: "\(citySlug)-place-\(index)",
                name: "\(city) \(Self.nameSuffixes[index])",
                rating: Self.ratings[index],
                entryFee: Self.entryFees[index],
                currency: "TL",
                imageURL: URL(string: "https://picsum.photos/seed/\(citySlug)place\(index)/300/200")
            )
        }
    }
}

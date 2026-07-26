//
//  Destination.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// A curated destination scored on the same trait axes as a `TravelPersona`, so the two can
/// be matched directly against each other.
struct Destination: Equatable {

    let cityName: String
    let countryName: String
    let iso2: String
    let tagline: String
    let climateHint: String
    let travelHint: String
    let dailyBudgetPerPerson: Int
    let affinity: [TravelTrait: Int]

    var country: Country {
        Country(
            name: countryName,
            iso2: iso2,
            flagURL: URL(string: "https://flagcdn.com/w80/\(iso2.lowercased()).png")
        )
    }

    var city: City {
        City(name: cityName)
    }

    /// How well this destination suits a traveler, as a 0...100 percentage.
    ///
    /// Weighted by the traveler's own scores so their *strong* preferences dominate: a
    /// destination that excels exactly where the traveler scores highest wins, while traits
    /// the traveler is indifferent about barely move the result.
    func matchScore(for persona: TravelPersona) -> Int {
        var weightedTotal = 0
        var maximumTotal = 0

        for trait in TravelTrait.allCases {
            let weight = persona.score(for: trait)
            weightedTotal += weight * (affinity[trait] ?? 0)
            maximumTotal += weight * 100
        }

        guard maximumTotal > 0 else { return 0 }
        return Int((Double(weightedTotal) / Double(maximumTotal) * 100).rounded())
    }

    /// The traits this destination serves best for a given traveler — drives the
    /// "neden burası?" explanation shown alongside a recommendation.
    func standoutTraits(for persona: TravelPersona, limit: Int = 3) -> [TravelTrait] {
        TravelTrait.allCases
            .filter { persona.score(for: $0) >= 40 && (affinity[$0] ?? 0) >= 60 }
            .sorted { (affinity[$0] ?? 0) * persona.score(for: $0) > (affinity[$1] ?? 0) * persona.score(for: $1) }
            .prefix(limit)
            .map { $0 }
    }
}

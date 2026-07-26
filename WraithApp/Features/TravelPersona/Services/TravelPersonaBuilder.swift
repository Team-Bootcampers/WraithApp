//
//  TravelPersonaBuilder.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Scores the character-analysis answers into a `TravelPersona`.
///
/// Each answer contributes points to one or more traits; the raw totals are then normalized
/// against the highest total that quiz could possibly produce for that trait, so every score
/// lands on a comparable 0...100 scale regardless of how many questions touch a given trait.
enum TravelPersonaBuilder {

    private static let weights: [String: [TravelTrait: Int]] = [
        // 1 — Motivation
        "relax": [.comfort: 3],
        "culture": [.culture: 3],
        "adventure": [.adventure: 3],
        "nightlife": [.social: 3, .gastronomy: 1],

        // 2 — Planning style
        "spontaneous": [.spontaneity: 3, .adventure: 1],
        "flexible": [.spontaneity: 2],
        "detailed": [.comfort: 1],

        // 3 — Budget priority
        "luxury_stay": [.comfort: 3],
        "food": [.gastronomy: 3],
        "activities": [.culture: 2, .adventure: 1],
        "shopping": [.comfort: 2, .social: 1],

        // 4 — Exploration approach
        "iconic": [.culture: 2, .social: 1],
        "hidden_gem": [.adventure: 2, .culture: 1, .spontaneity: 1],

        // 5 — Accommodation
        "resort": [.comfort: 3],
        "boutique_hotel": [.comfort: 2, .culture: 1],
        "airbnb": [.culture: 1, .spontaneity: 1, .social: 1],
        "camping": [.adventure: 3],

        // 6 — Daily pace
        "fast": [.pace: 3, .culture: 1],
        "slow": [.comfort: 1],
        "night_owl": [.social: 3, .pace: 1],

        // 7 — Food culture
        "foodie": [.gastronomy: 3, .culture: 1],
        "familiar": [.comfort: 1],
        "diet_specific": [.gastronomy: 2, .comfort: 1],

        // 8 — Local transport
        "public_transport": [.adventure: 1, .social: 2],
        "private_transport": [.comfort: 3],
        "guided_tours": [.culture: 2, .social: 2],

        // 9 — Stress tolerance
        "stressed": [.comfort: 2],
        "adaptable": [.spontaneity: 3, .adventure: 1],

        // 10 — Dream holiday in one word
        "peace": [.comfort: 3],
        "excitement": [.adventure: 3, .social: 1],
        "luxury": [.comfort: 3],
        "culture_word": [.culture: 3]
    ]

    static func build(from options: [QuizOption]) -> TravelPersona? {
        guard !options.isEmpty else { return nil }

        var rawScores: [TravelTrait: Int] = [:]
        for option in options {
            for (trait, points) in weights[option.value] ?? [:] {
                rawScores[trait, default: 0] += points
            }
        }

        var traits: [TravelTrait: Int] = [:]
        for trait in TravelTrait.allCases {
            let maximum = maximumPoints(for: trait)
            guard maximum > 0 else {
                traits[trait] = 0
                continue
            }
            let ratio = Double(rawScores[trait] ?? 0) / Double(maximum)
            traits[trait] = Int((ratio * 100).rounded())
        }

        return TravelPersona(traits: traits)
    }

    private static func maximumPoints(for trait: TravelTrait) -> Int {
        CharacterAnalysisQuestions.all.reduce(0) { total, question in
            total + (question.options.map { weights[$0.value]?[trait] ?? 0 }.max() ?? 0)
        }
    }
}

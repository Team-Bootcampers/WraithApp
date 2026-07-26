//
//  CompatibilityResult.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct CompatibilityResult {

    struct TraitScore {
        let trait: TravelTrait
        let score: Int
        let mine: Int
        let theirs: Int
    }

    let score: Int
    let traitScores: [TraitScore]
    let sharedStrengths: [TravelTrait]
    let frictionPoints: [TravelTrait]
    let verdictTitle: String
    let verdictDescription: String
    let blendedPersona: TravelPersona
    let suggestedDestination: Destination?
}

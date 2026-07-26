//
//  TravelPersonaStore.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Resolves the signed-in traveler's persona from their saved quiz answers.
/// Nothing extra is persisted — `QuizAnswerStore` already owns the source of truth, so the
/// persona is always derived from (and stays in sync with) the latest onboarding run.
enum TravelPersonaStore {

    static var current: TravelPersona? {
        TravelPersonaBuilder.build(from: QuizAnswerStore.shared.loadSelectedOptions())
    }
}

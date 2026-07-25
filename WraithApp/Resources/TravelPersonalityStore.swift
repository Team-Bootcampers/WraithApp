//
//  TravelPersonalityStore.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Persists the Gemini-generated character-analysis text from `/ai/travel-personality` so
/// later features (e.g. restaurant recommendations in Trip Creation) can reuse it without
/// re-running the analysis.
enum TravelPersonalityStore {

    private static let key = "com.voya.travelPersonalityAnalysis"

    static var current: String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func save(_ analysis: String) {
        UserDefaults.standard.set(analysis, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

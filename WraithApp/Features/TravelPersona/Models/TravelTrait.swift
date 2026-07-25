//
//  TravelTrait.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// The measurable axes a traveler's character-analysis answers are scored on.
/// Every persona-driven feature (itinerary planning, surprise destinations,
/// compatibility matching) reads these instead of the raw quiz answers.
enum TravelTrait: String, Codable, CaseIterable {
    case culture
    case adventure
    case comfort
    case gastronomy
    case spontaneity
    case social
    case pace

    var title: String {
        switch self {
        case .culture: return "Kültür"
        case .adventure: return "Macera"
        case .comfort: return "Konfor"
        case .gastronomy: return "Lezzet"
        case .spontaneity: return "Doğaçlama"
        case .social: return "Sosyallik"
        case .pace: return "Tempo"
        }
    }

    var iconName: String {
        switch self {
        case .culture: return "building.columns.fill"
        case .adventure: return "mountain.2.fill"
        case .comfort: return "sparkles"
        case .gastronomy: return "fork.knife"
        case .spontaneity: return "dice.fill"
        case .social: return "person.2.fill"
        case .pace: return "bolt.fill"
        }
    }
}

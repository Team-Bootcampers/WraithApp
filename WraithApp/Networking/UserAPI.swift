//
//  UserAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct UserResponseDto: Decodable {
    let id: String
    let firebaseUid: String
    let email: String
    let displayName: String?
    let isActive: Bool
    let isOnboarded: Bool
    let createdAt: String
}

private struct UpdateUserRequestDto: Encodable {
    let displayName: String
}

// MARK: - Onboarding enums (must match CoreBackendKit's OnboardingAnswersDto exactly)

enum TravelMotivation: String, Codable {
    case relaxation = "RELAXATION"
    case culture = "CULTURE"
    case adventure = "ADVENTURE"
    case foodNightlife = "FOOD_NIGHTLIFE"

    init?(appValue: String) {
        switch appValue {
        case "relax": self = .relaxation
        case "culture": self = .culture
        case "adventure": self = .adventure
        case "nightlife": self = .foodNightlife
        default: return nil
        }
    }
}

enum PlanningStyle: String, Codable {
    case spontaneous = "SPONTANEOUS"
    case flexible = "FLEXIBLE"
    case detailed = "DETAILED"

    init?(appValue: String) {
        switch appValue {
        case "spontaneous": self = .spontaneous
        case "flexible": self = .flexible
        case "detailed": self = .detailed
        default: return nil
        }
    }
}

enum BudgetPriority: String, Codable {
    case luxuryStay = "LUXURY_STAY"
    case fineDining = "FINE_DINING"
    case activities = "ACTIVITIES"
    case shopping = "SHOPPING"

    init?(appValue: String) {
        switch appValue {
        case "luxury_stay": self = .luxuryStay
        case "food": self = .fineDining
        case "activities": self = .activities
        case "shopping": self = .shopping
        default: return nil
        }
    }
}

enum ExplorationApproach: String, Codable {
    case iconic = "ICONIC"
    case hiddenGems = "HIDDEN_GEMS"

    init?(appValue: String) {
        switch appValue {
        case "iconic": self = .iconic
        case "hidden_gem": self = .hiddenGems
        default: return nil
        }
    }
}

enum AccommodationPreference: String, Codable {
    case resort = "RESORT"
    case boutiqueHotel = "BOUTIQUE_HOTEL"
    case airbnb = "AIRBNB"
    case campingGlamping = "CAMPING_GLAMPING"

    init?(appValue: String) {
        switch appValue {
        case "resort": self = .resort
        case "boutique_hotel": self = .boutiqueHotel
        case "airbnb": self = .airbnb
        case "camping": self = .campingGlamping
        default: return nil
        }
    }
}

enum TravelPace: String, Codable {
    case fast = "FAST"
    case slow = "SLOW"
    case nightOwl = "NIGHT_OWL"

    init?(appValue: String) {
        switch appValue {
        case "fast": self = .fast
        case "slow": self = .slow
        case "night_owl": self = .nightOwl
        default: return nil
        }
    }
}

enum FoodCulture: String, Codable {
    case foodie = "FOODIE"
    case safeFamiliar = "SAFE_FAMILIAR"
    case healthyDiet = "HEALTHY_DIET"

    init?(appValue: String) {
        switch appValue {
        case "foodie": self = .foodie
        case "familiar": self = .safeFamiliar
        case "diet_specific": self = .healthyDiet
        default: return nil
        }
    }
}

enum TransportPreference: String, Codable {
    case publicTransport = "PUBLIC_TRANSPORT"
    case privateCar = "PRIVATE_CAR"
    case guidedTours = "GUIDED_TOURS"

    init?(appValue: String) {
        switch appValue {
        case "public_transport": self = .publicTransport
        case "private_transport": self = .privateCar
        case "guided_tours": self = .guidedTours
        default: return nil
        }
    }
}

enum StressTolerance: String, Codable {
    case needsBackupPlan = "NEEDS_BACKUP_PLAN"
    case goesWithFlow = "GOES_WITH_FLOW"

    init?(appValue: String) {
        switch appValue {
        case "stressed": self = .needsBackupPlan
        case "adaptable": self = .goesWithFlow
        default: return nil
        }
    }
}

enum IdealVacationSummary: String, Codable {
    case peace = "PEACE"
    case excitement = "EXCITEMENT"
    case luxury = "LUXURY"
    case culture = "CULTURE"

    init?(appValue: String) {
        switch appValue {
        case "peace": self = .peace
        case "excitement": self = .excitement
        case "luxury": self = .luxury
        case "culture_word": self = .culture
        default: return nil
        }
    }
}

struct OnboardingAnswersDto: Codable {
    let travelMotivation: TravelMotivation
    let planningStyle: PlanningStyle
    let budgetPriority: BudgetPriority
    let explorationApproach: ExplorationApproach
    let accommodationPreference: AccommodationPreference
    let travelPace: TravelPace
    let foodCulture: FoodCulture
    let transportPreference: TransportPreference
    let stressTolerance: StressTolerance
    let idealVacationSummary: IdealVacationSummary
}

private struct SaveOnboardingRequestDto: Encodable {
    let answers: OnboardingAnswersDto
}

/// Wraps `/users` and `/users/{id}/onboarding` from the CoreBackendKit API.
enum UserAPI {

    static func getById(_ id: String, token: String) async throws -> UserResponseDto {
        try await APIClient.shared.request(path: "/users/\(id)", method: "GET", authToken: token)
    }

    static func update(_ id: String, displayName: String, token: String) async throws -> UserResponseDto {
        try await APIClient.shared.request(
            path: "/users/\(id)",
            method: "PATCH",
            body: UpdateUserRequestDto(displayName: displayName),
            authToken: token
        )
    }

    static func saveOnboarding(_ id: String, answers: OnboardingAnswersDto, token: String) async throws -> UserResponseDto {
        try await APIClient.shared.request(
            path: "/users/\(id)/onboarding",
            method: "PUT",
            body: SaveOnboardingRequestDto(answers: answers),
            authToken: token
        )
    }

    static func getOnboarding(_ id: String, token: String) async throws -> OnboardingAnswersDto? {
        try await APIClient.shared.request(path: "/users/\(id)/onboarding", method: "GET", authToken: token)
    }
}

//
//  SurpriseTripAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct SurpriseTripRequestDto: Encodable {
    let characterAnalysis: String
    let onboardingAnswers: OnboardingAnswersDto
    let travelerCount: Int
    let durationInDays: Int
    let startDate: String
    let budget: SurpriseTripBudgetDto
    let departureCountry: TripPlanningCountryDto
    let departureCityName: String
    let surpriseScope: String
    let excludedCountryNames: [String]
}

struct SurpriseTripBudgetDto: Encodable {
    let amount: Double
    let currency: String
}

struct SurpriseTripResponseDto: Decodable {
    let destinationReveal: SurpriseDestinationRevealDto
    let tripTitle: String
    let tripSummary: String
    let matchScore: Double
    let personalizedInsights: [String]
    let totalEstimatedCost: TripPlanningCostDto
    let budgetBreakdown: TripPlanningBudgetBreakdownDto
    let recommendedHotels: [SurpriseRecommendedHotelDto]
    let stops: [TripPlanningResponseStopDto]
    let warnings: [TripPlanningWarningDto]
}

struct SurpriseDestinationRevealDto: Decodable {
    let countryName: String
    let cityName: String
    let teaserTitle: String
    let whyThisPlace: String
}

struct SurpriseRecommendedHotelDto: Decodable {
    let id: String
    let name: String
    let rating: Double
    let pricePerNight: Double
    let currency: String
    let imageUrl: String?
}

/// Wraps `POST /ai/surprise-trip` — no destination is chosen up front, Gemini picks one from
/// the traveler's character analysis, onboarding answers, budget and duration, and returns a
/// full itinerary alongside the reveal.
enum SurpriseTripAPI {

    static func plan(request: SurpriseTripRequestDto, token: String?) async throws -> SurpriseTripResponseDto {
        try await APIClient.shared.request(
            path: "/ai/surprise-trip",
            method: "POST",
            body: request,
            authToken: token
        )
    }
}

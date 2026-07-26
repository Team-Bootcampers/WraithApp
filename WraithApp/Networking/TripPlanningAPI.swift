//
//  TripPlanningAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct TripPlanningRequestDto: Encodable {
    let characterAnalysis: String
    let onboardingAnswers: OnboardingAnswersDto
    let trip: TripPlanningTripDto
}

struct TripPlanningTripDto: Encodable {
    let travelerCount: Int
    let stops: [TripPlanningStopDto]
}

struct TripPlanningStopDto: Encodable {
    let stopNumber: Int
    let country: TripPlanningCountryDto?
    let cityName: String?
    let startDate: String
    let endDate: String
    let transportType: String
    let ticketPrice: TripPlanningTicketPriceDto
    let selectedHotels: [TripPlanningHotelDto]
    let selectedPlaces: [TripPlanningPlaceDto]
    let selectedRestaurants: [TripPlanningRestaurantDto]
}

struct TripPlanningCountryDto: Encodable {
    let name: String
    let iso2: String
}

struct TripPlanningTicketPriceDto: Encodable {
    let minPrice: Double
    let currency: String
}

struct TripPlanningHotelDto: Encodable {
    let id: String
    let name: String
    let rating: Double
    let pricePerNight: Int
    let currency: String
}

struct TripPlanningPlaceDto: Encodable {
    let id: String
    let name: String
    let rating: Double
    let entryFee: Int
}

struct TripPlanningRestaurantDto: Encodable {
    let id: String
    let name: String
    let rating: Double
    let averagePricePerPerson: Int
}

struct TripPlanningResponseDto: Decodable {
    let tripTitle: String
    let tripSummary: String
    let matchScore: Double
    let personalizedInsights: [String]
    let totalEstimatedCost: TripPlanningCostDto
    let budgetBreakdown: TripPlanningBudgetBreakdownDto
    let stops: [TripPlanningResponseStopDto]
    let warnings: [TripPlanningWarningDto]
}

struct TripPlanningCostDto: Decodable {
    let amount: Double
    let currency: String
}

struct TripPlanningBudgetBreakdownDto: Decodable {
    let accommodation: Double
    let food: Double
    let activities: Double
    let transport: Double
    let buffer: Double
    let currency: String
}

struct TripPlanningResponseStopDto: Decodable {
    let stopNumber: Int
    let cityName: String
    let countryName: String
    let arrivalDate: String
    let departureDate: String
    let weatherForecastHint: String?
    let localTips: [String]
    let packingList: [String]
    let days: [TripPlanningDayDto]
}

struct TripPlanningDayDto: Decodable {
    let dayNumber: Int
    let date: String
    let theme: String?
    let timeline: [TripPlanningTimelineItemDto]
}

struct TripPlanningTimelineItemDto: Decodable {
    let timeOfDay: String
    let startTime: String
    let endTime: String
    let title: String
    let description: String
    let category: String
    let location: String?
    let estimatedCost: Double
}

struct TripPlanningWarningDto: Decodable {
    let type: String
    let message: String
}

/// Wraps `/ai/trip-planning` — takes the user's character analysis, onboarding answers and
/// the full trip (all stops with their selected hotels/places/restaurants), and returns a
/// Gemini-generated day-by-day, hour-by-hour plan.
enum TripPlanningAPI {

    static func generatePlan(request: TripPlanningRequestDto, token: String?) async throws -> TripPlanningResponseDto {
        try await APIClient.shared.request(
            path: "/ai/trip-planning",
            method: "POST",
            body: request,
            authToken: token
        )
    }
}

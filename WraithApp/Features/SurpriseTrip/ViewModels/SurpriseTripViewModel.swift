//
//  SurpriseTripViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum SurpriseTripError: Error, LocalizedError {
    case missingCharacterAnalysis
    case missingOnboardingAnswers

    var errorDescription: String? {
        switch self {
        case .missingCharacterAnalysis, .missingOnboardingAnswers:
            return "Sürpriz bir seyahat hazırlamak için önce karakter analizini tamamlaman gerekiyor."
        }
    }
}

final class SurpriseTripViewModel {

    // MARK: - Properties

    private let persona: TravelPersona

    private(set) var plan: ItineraryPlan?
    private(set) var isRevealed = false

    /// Only used as a display hint and as the request's `durationInDays` — the backend, not
    /// this heuristic, is what actually decides the itinerary length.
    var nights: Int {
        SmartItineraryPlanner.recommendedNights(for: persona)
    }

    private static let departureCountry = TripPlanningCountryDto(name: "Turkey", iso2: "TR")
    private static let departureCityName = "İstanbul"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    // MARK: - Init

    init(persona: TravelPersona) {
        self.persona = persona
    }

    // MARK: - Surprise

    /// Calls `/ai/surprise-trip` — the destination is picked by the backend, the reveal here
    /// is purely presentational, so the plan behind it is always real.
    @discardableResult
    func prepareSurprise(startDate: Date, travelerCount: Int, budgetPerPerson: Int) async throws -> ItineraryPlan {
        isRevealed = false

        guard let characterAnalysis = TravelPersonalityStore.current else {
            throw SurpriseTripError.missingCharacterAnalysis
        }
        guard
            let answers = QuizAnswerStore.shared.loadSavedAnswers(),
            let onboardingAnswers = OnboardingMapper.map(answers)
        else {
            throw SurpriseTripError.missingOnboardingAnswers
        }

        let request = SurpriseTripRequestDto(
            characterAnalysis: characterAnalysis,
            onboardingAnswers: onboardingAnswers,
            travelerCount: travelerCount,
            durationInDays: nights,
            startDate: Self.dateFormatter.string(from: startDate),
            budget: SurpriseTripBudgetDto(amount: Double(budgetPerPerson * travelerCount), currency: "TRY"),
            departureCountry: Self.departureCountry,
            departureCityName: Self.departureCityName,
            surpriseScope: "ANYWHERE",
            excludedCountryNames: []
        )

        let response = try await SurpriseTripAPI.plan(request: request, token: UserSession.shared.idToken)
        let plan = Self.makePlan(from: response, travelerCount: travelerCount, budgetPerPerson: budgetPerPerson)
        self.plan = plan
        return plan
    }

    func reveal() {
        isRevealed = true
    }

    func save() -> SavedTrip? {
        guard let plan else { return nil }
        TripStore.shared.save(plan.trip)
        return plan.trip
    }

    // MARK: - Mapping

    private static func makePlan(from response: SurpriseTripResponseDto, travelerCount: Int, budgetPerPerson: Int) -> ItineraryPlan {
        let reveal = response.destinationReveal
        let destination = Destination(
            cityName: reveal.cityName,
            countryName: reveal.countryName,
            iso2: "",
            tagline: reveal.teaserTitle,
            climateHint: response.stops.first?.weatherForecastHint ?? reveal.whyThisPlace,
            travelHint: response.stops.first?.localTips.first ?? response.tripSummary,
            dailyBudgetPerPerson: budgetPerPerson,
            affinity: [:]
        )

        let hotels = response.recommendedHotels.map {
            Hotel(id: $0.id, name: $0.name, rating: $0.rating, pricePerNight: Int($0.pricePerNight.rounded()), currency: $0.currency, imageURL: $0.imageUrl.flatMap(URL.init(string:)))
        }
        let selectedHotelIDs = Set(hotels.map(\.id))

        let stops = response.stops.enumerated().map { index, stopDto in
            TripStopSnapshot(
                stopNumber: stopDto.stopNumber,
                departureCityName: departureCityName,
                country: Country(name: stopDto.countryName, iso2: "", flagURL: nil),
                cityName: stopDto.cityName,
                travelerCount: travelerCount,
                startDate: dateFormatter.date(from: stopDto.arrivalDate),
                endDate: dateFormatter.date(from: stopDto.departureDate),
                transportType: .airplane,
                // The backend recommends hotels for the trip as a whole, not per stop — they're
                // attached to the first stop only so they don't get double-counted in cost totals.
                hotels: index == 0 ? hotels : [],
                selectedHotelIDs: index == 0 ? selectedHotelIDs : [],
                places: [],
                selectedPlaceIDs: [],
                restaurants: [],
                selectedRestaurantIDs: []
            )
        }

        var trip = SavedTrip(stops: stops)
        trip.estimatedTotalCostAmount = response.totalEstimatedCost.amount
        trip.estimatedTotalCostCurrency = response.totalEstimatedCost.currency

        return ItineraryPlan(
            destinations: [destination],
            trip: trip,
            matchScore: Int(response.matchScore.rounded()),
            highlights: response.personalizedInsights
        )
    }
}

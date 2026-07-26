//
//  TripPlanningService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum TripPlanningError: Error, LocalizedError {
    case missingCharacterAnalysis

    var errorDescription: String? {
        "Detaylı gezi planı oluşturmak için önce karakter analizini tamamlaman gerekiyor."
    }
}

/// Calls `/ai/trip-planning` with the trip's parameters and the user's character analysis,
/// then renders the response into a themed PDF stored in the Documents directory.
struct TripPlanGenerationResult {
    let fileName: String
    let totalEstimatedCost: TripPlanningCostDto
}

final class TripPlanningService {

    func generatePlanPDF(for trip: SavedTrip) async throws -> TripPlanGenerationResult {
        guard let characterAnalysis = TravelPersonalityStore.current else {
            throw TripPlanningError.missingCharacterAnalysis
        }
        guard
            let answers = QuizAnswerStore.shared.loadSavedAnswers(),
            let onboardingAnswers = OnboardingMapper.map(answers)
        else {
            throw TripPlanningError.missingCharacterAnalysis
        }

        let travelerCount = trip.stops.first?.travelerCount ?? 1
        let request = TripPlanningRequestDto(
            characterAnalysis: characterAnalysis,
            onboardingAnswers: onboardingAnswers,
            trip: TripPlanningTripDto(
                travelerCount: travelerCount,
                stops: trip.stops.map(Self.makeStopDto)
            )
        )

        let response = try await TripPlanningAPI.generatePlan(request: request, token: UserSession.shared.idToken)

        let pdfData = TripPlanPDFGenerator().renderPDF(response: response, travelerCount: travelerCount)
        let fileName = "trip-\(trip.id.uuidString).pdf"
        try pdfData.write(to: TripPlanFileStore.fileURL(for: fileName))
        return TripPlanGenerationResult(fileName: fileName, totalEstimatedCost: response.totalEstimatedCost)
    }

    private static func makeStopDto(_ stop: TripStopSnapshot) -> TripPlanningStopDto {
        TripPlanningStopDto(
            stopNumber: stop.stopNumber,
            country: stop.country.map { TripPlanningCountryDto(name: $0.name, iso2: $0.iso2) },
            cityName: stop.cityName,
            startDate: dateFormatter.string(from: stop.startDate ?? Date()),
            endDate: dateFormatter.string(from: stop.endDate ?? Date()),
            transportType: backendTransportValue(stop.transportType),
            // The app doesn't fetch real ticket prices yet (see `TicketSearchURLBuilder`,
            // which only builds outbound search links) — the backend requires a non-null
            // object here, so a zeroed placeholder is sent until that data exists.
            ticketPrice: TripPlanningTicketPriceDto(minPrice: 0, currency: "TRY"),
            selectedHotels: stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }.map {
                TripPlanningHotelDto(id: $0.id, name: $0.name, rating: $0.rating, pricePerNight: $0.pricePerNight, currency: $0.currency)
            },
            selectedPlaces: stop.places.filter { stop.selectedPlaceIDs.contains($0.id) }.map {
                TripPlanningPlaceDto(id: $0.id, name: $0.name, rating: $0.rating, entryFee: $0.entryFee)
            },
            selectedRestaurants: stop.restaurants.filter { stop.selectedRestaurantIDs.contains($0.id) }.map {
                TripPlanningRestaurantDto(id: $0.id, name: $0.name, rating: $0.rating, averagePricePerPerson: $0.averagePricePerPerson)
            }
        )
    }

    private static func backendTransportValue(_ type: TransportType) -> String {
        switch type {
        case .airplane: return "AIRPLANE"
        case .bus: return "BUS"
        case .car: return "CAR"
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}

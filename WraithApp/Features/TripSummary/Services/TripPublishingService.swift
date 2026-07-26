//
//  TripPublishingService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Creates a trip on the backend (`POST /trips`) and toggles whether it's visible to other
/// users via `POST /trips/{id}/publish` and `POST /trips/{id}/unpublish`.
protocol TripPublishingServiceProtocol {
    func createTrip(_ trip: SavedTrip) async throws -> String
    func publishTrip(tripID: String, title: String, description: String) async throws
    func unpublishTrip(tripID: String) async throws
}

final class TripPublishingService: TripPublishingServiceProtocol {

    func createTrip(_ trip: SavedTrip) async throws -> String {
        guard let userId = UserSession.shared.userId else {
            throw TripPublishingError.notLoggedIn
        }
        let request = CreateTripRequestDto(
            userId: userId,
            stops: trip.stops.map(Self.makeStopDto),
            isPublic: false
        )
        let response = try await TripAPI.createTrip(request: request, token: UserSession.shared.idToken)
        return response.id
    }

    func publishTrip(tripID: String, title: String, description: String) async throws {
        try await TripPublishingAPI.publishTrip(
            id: tripID,
            title: title,
            description: description,
            token: UserSession.shared.idToken
        )
    }

    func unpublishTrip(tripID: String) async throws {
        try await TripPublishingAPI.unpublishTrip(id: tripID, token: UserSession.shared.idToken)
    }

    private static func makeStopDto(_ stop: TripStopSnapshot) -> CreateTripStopDto {
        let country = stop.country?.name ?? ""
        let cityName = stop.cityName ?? ""
        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        let selectedPlaces = stop.places.filter { stop.selectedPlaceIDs.contains($0.id) }
        let selectedRestaurants = stop.restaurants.filter { stop.selectedRestaurantIDs.contains($0.id) }

        return CreateTripStopDto(
            stopNumber: stop.stopNumber,
            country: country,
            cityName: cityName,
            startDate: dateFormatter.string(from: stop.startDate ?? Date()),
            endDate: dateFormatter.string(from: stop.endDate ?? Date()),
            personCount: stop.travelerCount,
            transportType: backendTransportValue(stop.transportType),
            totalCost: CreateTripCostDto(
                amount: Double(
                    selectedHotels.reduce(0) { $0 + $1.pricePerNight }
                        + selectedPlaces.reduce(0) { $0 + $1.entryFee } * stop.travelerCount
                        + selectedRestaurants.reduce(0) { $0 + $1.averagePricePerPerson } * stop.travelerCount
                ),
                currency: selectedHotels.first?.currency ?? selectedRestaurants.first?.currency ?? selectedPlaces.first?.currency ?? "TL"
            ),
            // Hotels/places have no address data of their own (they're mocked locally, not
            // fetched from a backend with address info) — the city name is the best available
            // substitute and satisfies the backend's non-empty `address` requirement.
            hotels: selectedHotels.map { makePlaceDto(id: $0.id, name: $0.name, rating: $0.rating, amount: Double($0.pricePerNight), currency: $0.currency, period: "night", imageURL: $0.imageURL, address: cityName, country: country, cityName: cityName) },
            attractions: selectedPlaces.map { makePlaceDto(id: $0.id, name: $0.name, rating: $0.rating, amount: Double($0.entryFee), currency: $0.currency, period: "entry", imageURL: $0.imageURL, address: cityName, country: country, cityName: cityName) },
            restaurants: selectedRestaurants.map { makePlaceDto(id: $0.id, name: $0.name, rating: $0.rating, amount: Double($0.averagePricePerPerson), currency: $0.currency, period: "person", imageURL: $0.imageURL, address: $0.address, country: country, cityName: cityName) }
        )
    }

    private static func makePlaceDto(id: String, name: String, rating: Double, amount: Double, currency: String, period: String, imageURL: URL?, address: String, country: String, cityName: String) -> CreateTripPlaceDto {
        CreateTripPlaceDto(
            id: id,
            name: name,
            rating: rating,
            address: address,
            price: CreateTripPriceDto(amount: amount, currency: currency, period: period),
            images: imageURL.map { [$0.absoluteString] } ?? [],
            country: country,
            cityName: cityName
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

enum TripPublishingError: Error, LocalizedError {
    case notLoggedIn
    case missingTrip

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "Seyahati paylaşmak için giriş yapmış olman gerekiyor."
        case .missingTrip:
            return "Bu seyahat henüz kaydedilmemiş."
        }
    }
}

final class MockTripPublishingService: TripPublishingServiceProtocol {

    func createTrip(_ trip: SavedTrip) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        return UUID().uuidString
    }

    func publishTrip(tripID: String, title: String, description: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func unpublishTrip(tripID: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}

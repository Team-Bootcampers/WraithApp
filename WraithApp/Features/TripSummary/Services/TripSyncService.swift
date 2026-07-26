//
//  TripSyncService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Maps `SavedTrip` to/from the backend's `/trips` shape. Guest-mode trips live entirely in
/// `TripStore`; once logged in, `TripRepository` routes everything through here instead.
final class TripSyncService {

    // MARK: - Push

    /// Pushes a single trip up to the backend under the current user's id. No-ops (does
    /// nothing, throws nothing) if nobody's logged in.
    func push(_ trip: SavedTrip) async throws {
        guard let userId = UserSession.shared.userId else { return }
        let requestDto = Self.makeRequestDto(for: trip, userId: userId)
        if let data = try? JSONEncoder().encode(requestDto), let json = String(data: data, encoding: .utf8) {
            print("📤 [TripSync] POST /trips body:\n\(json)")
        }
        do {
            try await TripSyncAPI.syncTrip(requestDto, token: UserSession.shared.idToken)
            print("✅ [TripSync] POST /trips succeeded")
        } catch {
            print("❌ [TripSync] POST /trips failed: \(error)")
            throw error
        }
    }

    /// Pushes every locally-saved trip up to the backend right after the user logs in or
    /// signs up, so trips built as a guest (before having an account) end up associated
    /// with their new `userId` too.
    func syncAllSavedTrips() async {
        for trip in TripStore.shared.loadTrips() {
            // Browsed-preview trips (saved straight from a Home card) have no itinerary
            // yet — there's nothing to sync until they're actually built out.
            guard !trip.stops.isEmpty else { continue }

            do {
                try await push(trip)
            } catch {
                // Best-effort: the trip stays safely in local storage and gets another
                // chance on the next login.
            }
        }
    }

    // MARK: - Fetch

    /// Pulls the current user's trips down from the backend. Returns `[]` if nobody's
    /// logged in, rather than throwing.
    func fetchRemoteTrips() async throws -> [SavedTrip] {
        guard let userId = UserSession.shared.userId else { return [] }
        let responses = try await TripSyncAPI.fetchTrips(userId: userId, token: UserSession.shared.idToken)
        print("📥 [TripSync] GET /trips → \(responses.count) trip(s):")
        responses.forEach { print($0) }
        return responses.map(Self.makeSavedTrip)
    }

    // MARK: - SavedTrip → DTO

    private static func makeRequestDto(for trip: SavedTrip, userId: String) -> SyncTripRequestDto {
        let costCalculator = TripSummaryViewModel(trip: trip)
        let preview = trip.browsedTripPreview
        return SyncTripRequestDto(
            userId: userId,
            stopCount: trip.stops.count,
            stops: trip.stops.map { makeStopDto($0, costCalculator: costCalculator) },
            isPublic: trip.isPublic,
            title: preview?.title ?? defaultTitle(for: trip),
            description: preview?.description ?? "",
            coverImage: preview?.imageURL?.absoluteString ?? defaultCoverImage(for: trip),
            durationDays: preview?.durationInDays ?? defaultDurationDays(for: trip),
            viewCount: 0,
            ratingAverage: preview?.rating ?? 0,
            ratingCount: preview?.reviewCount ?? 0,
            createdAt: isoFormatter.string(from: trip.createdAt),
            updatedAt: isoFormatter.string(from: Date())
        )
    }

    private static func defaultTitle(for trip: SavedTrip) -> String {
        let cityNames = trip.stops.compactMap { $0.cityName }
        return cityNames.isEmpty ? "Seyahat" : cityNames.joined(separator: " → ")
    }

    private static func defaultCoverImage(for trip: SavedTrip) -> String {
        for stop in trip.stops {
            if let url = stop.hotels.first?.imageURL { return url.absoluteString }
            if let url = stop.places.first?.imageURL { return url.absoluteString }
        }
        return ""
    }

    private static func defaultDurationDays(for trip: SavedTrip) -> Int {
        guard let start = trip.stops.first?.startDate, let end = trip.stops.last?.endDate else { return 0 }
        return max(Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0, 0)
    }

    private static func makeStopDto(_ stop: TripStopSnapshot, costCalculator: TripSummaryViewModel) -> SyncTripStopDto {
        let countryName = stop.country?.name ?? ""
        let cityName = stop.cityName ?? ""

        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        let hotelsToSend = selectedHotels.isEmpty
            ? Array(stop.hotels.min(by: { $0.pricePerNight < $1.pricePerNight }).map { [$0] } ?? [])
            : selectedHotels
        let selectedPlaces = stop.places.filter { stop.selectedPlaceIDs.contains($0.id) }
        let selectedRestaurants = stop.restaurants.filter { stop.selectedRestaurantIDs.contains($0.id) }

        // The app doesn't collect a real street address for hotels/places/restaurants yet —
        // the backend rejects an empty string, so fall back to city + country.
        let fallbackAddress = [cityName, countryName].filter { !$0.isEmpty }.joined(separator: ", ")

        return SyncTripStopDto(
            stopNumber: stop.stopNumber,
            country: countryName,
            cityName: cityName,
            startDate: dateFormatter.string(from: stop.startDate ?? Date()),
            endDate: dateFormatter.string(from: stop.endDate ?? Date()),
            personCount: stop.travelerCount,
            transportType: backendTransportValue(stop.transportType),
            totalCost: SyncTripCostDto(amount: costCalculator.totalCost(for: stop), currency: "TRY"),
            hotels: hotelsToSend.map {
                SyncTripPlaceDto(
                    id: $0.id,
                    name: $0.name,
                    rating: $0.rating,
                    address: fallbackAddress,
                    price: SyncTripPriceDto(amount: $0.pricePerNight, currency: $0.currency, period: "night"),
                    images: $0.imageURL.map { [$0.absoluteString] } ?? [],
                    country: countryName,
                    cityName: cityName
                )
            },
            attractions: selectedPlaces.map {
                SyncTripPlaceDto(
                    id: $0.id,
                    name: $0.name,
                    rating: $0.rating,
                    address: fallbackAddress,
                    price: SyncTripPriceDto(amount: $0.entryFee, currency: $0.currency, period: "entry"),
                    images: $0.imageURL.map { [$0.absoluteString] } ?? [],
                    country: countryName,
                    cityName: cityName
                )
            },
            restaurants: selectedRestaurants.map {
                SyncTripPlaceDto(
                    id: $0.id,
                    name: $0.name,
                    rating: $0.rating,
                    address: fallbackAddress,
                    price: SyncTripPriceDto(amount: $0.averagePricePerPerson, currency: $0.currency, period: "person"),
                    images: $0.imageURL.map { [$0.absoluteString] } ?? [],
                    country: countryName,
                    cityName: cityName
                )
            }
        )
    }

    // MARK: - DTO → SavedTrip

    /// Lossy by construction: the backend schema only round-trips what it was sent (no hotel
    /// images, no place/restaurant currency, no `browsedTripPreview`), so this fills in
    /// reasonable defaults for anything the API doesn't carry.
    private static func makeSavedTrip(from dto: SyncTripResponseDto) -> SavedTrip {
        SavedTrip(
            id: UUID(uuidString: dto.id) ?? UUID(),
            stops: dto.stops.map(makeStopSnapshot),
            isPublic: dto.isPublic
        )
    }

    private static func makeStopSnapshot(from dto: SyncTripStopDto) -> TripStopSnapshot {
        let hotels = dto.hotels.map {
            Hotel(
                id: $0.id,
                name: $0.name,
                rating: $0.rating,
                pricePerNight: $0.price.amount,
                currency: $0.price.currency,
                imageURL: $0.images.first.flatMap(URL.init(string:))
            )
        }
        let places = dto.attractions.map {
            Place(
                id: $0.id,
                name: $0.name,
                rating: $0.rating,
                entryFee: $0.price.amount,
                currency: $0.price.currency,
                imageURL: $0.images.first.flatMap(URL.init(string:))
            )
        }
        let restaurants = dto.restaurants.map {
            Restaurant(
                id: $0.id,
                name: $0.name,
                rating: $0.rating,
                averagePricePerPerson: $0.price.amount,
                currency: $0.price.currency,
                imageURL: $0.images.first.flatMap(URL.init(string:))
            )
        }

        return TripStopSnapshot(
            stopNumber: dto.stopNumber,
            departureCityName: nil,
            country: Country(name: dto.country, iso2: "", flagURL: nil),
            cityName: dto.cityName,
            travelerCount: dto.personCount,
            startDate: dateFormatter.date(from: dto.startDate),
            endDate: dateFormatter.date(from: dto.endDate),
            transportType: transportType(from: dto.transportType),
            hotels: hotels,
            selectedHotelIDs: Set(hotels.map(\.id)),
            places: places,
            selectedPlaceIDs: Set(places.map(\.id)),
            restaurants: restaurants,
            selectedRestaurantIDs: Set(restaurants.map(\.id))
        )
    }

    private static func transportType(from backendValue: String) -> TransportType {
        switch backendValue {
        case "BUS": return .bus
        case "CAR": return .car
        default: return .airplane
        }
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

    private static let isoFormatter = ISO8601DateFormatter()
}

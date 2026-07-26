//
//  PopularTripsService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Backs `PopularTripsServiceProtocol` with the real `GET /trips` endpoint, always scoped to
/// public trips.
final class PopularTripsService: PopularTripsServiceProtocol {

    func fetchTrips(query: String?, sortOption: PopularTripSortOption) async throws -> [PopularTrip] {
        // `personalized=true` requires both a logged-in user and a character analysis to send
        // as `personalityAnalysis` — without those the backend has nothing to personalize with,
        // so this falls back to the plain public list (sorted locally, same placeholder as before).
        let isPersonalized = sortOption == .personalized
            && UserSession.shared.isLoggedIn
            && TravelPersonalityStore.current != nil

        let dtos = try await TripAPI.fetchTrips(
            userId: isPersonalized ? UserSession.shared.userId : nil,
            isPublic: true,
            popular: sortOption == .popularity,
            personalized: isPersonalized,
            personalityAnalysis: isPersonalized ? TravelPersonalityStore.current : nil,
            token: UserSession.shared.idToken
        )

        var trips = dtos.map(Self.makeTrip)

        if let query, !query.isEmpty {
            trips = trips.filter { $0.title.localizedStandardContains(query) }
        }

        switch sortOption {
        case .popularity:
            break // already sorted by view count server-side via `popular=true`
        case .price:
            trips.sort { $0.price < $1.price }
        case .rating:
            trips.sort { $0.rating > $1.rating }
        case .personalized:
            if !isPersonalized {
                trips.sort { $0.popularityScore > $1.popularityScore }
            }
        }

        return trips
    }

    private static func makeTrip(from dto: TripListItemDto) -> PopularTrip {
        let totalAmount = dto.stops.reduce(0) { $0 + $1.totalCost.amount }
        let currency = dto.stops.first?.totalCost.currency ?? "TL"

        return PopularTrip(
            id: dto.id,
            title: dto.title,
            imageURL: URL(string: dto.coverImage),
            rating: dto.ratingAverage,
            reviewCount: dto.ratingCount,
            durationInDays: dto.durationDays,
            description: dto.description,
            price: Int(totalAmount.rounded()),
            currency: currency,
            popularityScore: dto.viewCount,
            stops: dto.stops.map(Self.makeStopSnapshot)
        )
    }

    private static func makeStopSnapshot(from dto: TripListItemStopDto) -> TripStopSnapshot {
        let hotels = dto.hotels.map {
            Hotel(id: $0.id, name: $0.name, rating: $0.rating, pricePerNight: Int($0.price.amount.rounded()), currency: $0.price.currency, imageURL: $0.images.first.flatMap(URL.init(string:)))
        }
        let places = dto.attractions.map {
            Place(id: $0.id, name: $0.name, rating: $0.rating, entryFee: Int($0.price.amount.rounded()), currency: $0.price.currency, imageURL: $0.images.first.flatMap(URL.init(string:)))
        }
        let restaurants = dto.restaurants.map {
            Restaurant(id: $0.id, name: $0.name, rating: $0.rating, averagePricePerPerson: Int($0.price.amount.rounded()), currency: $0.price.currency, imageURL: $0.images.first.flatMap(URL.init(string:)), address: $0.address)
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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}

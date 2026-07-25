//
//  SmartItineraryPlanner.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Turns a `TravelPersona` into a complete, savable trip.
///
/// Reuses the exact same services the manual Trip Creation flow uses, so an auto-generated
/// trip is indistinguishable from a hand-built one and stays fully editable afterwards.
final class SmartItineraryPlanner {

    // MARK: - Properties

    private let hotelService: HotelServiceProtocol
    private let placeService: PlaceServiceProtocol
    private let restaurantService: RestaurantServiceProtocol

    // MARK: - Init

    init(
        hotelService: HotelServiceProtocol = MockHotelService(),
        placeService: PlaceServiceProtocol = MockPlaceService(),
        restaurantService: RestaurantServiceProtocol = MockRestaurantService()
    ) {
        self.hotelService = hotelService
        self.placeService = placeService
        self.restaurantService = restaurantService
    }

    // MARK: - Planning

    func plan(
        for persona: TravelPersona,
        destinations: [Destination],
        startDate: Date,
        nightsPerStop: Int,
        travelerCount: Int
    ) async -> ItineraryPlan {
        var stops: [TripStopSnapshot] = []
        var cursor = startDate

        for (index, destination) in destinations.enumerated() {
            let endDate = Calendar.current.date(byAdding: .day, value: nightsPerStop, to: cursor) ?? cursor
            let stop = await makeStop(
                stopNumber: index + 1,
                destination: destination,
                persona: persona,
                startDate: cursor,
                endDate: endDate,
                travelerCount: travelerCount
            )
            stops.append(stop)
            cursor = endDate
        }

        let matchScore = destinations.isEmpty
            ? 0
            : destinations.map { $0.matchScore(for: persona) }.reduce(0, +) / destinations.count

        return ItineraryPlan(
            destinations: destinations,
            trip: SavedTrip(stops: stops),
            matchScore: matchScore,
            highlights: highlights(for: persona, destinations: destinations, nights: nightsPerStop)
        )
    }

    private func makeStop(
        stopNumber: Int,
        destination: Destination,
        persona: TravelPersona,
        startDate: Date,
        endDate: Date,
        travelerCount: Int
    ) async -> TripStopSnapshot {
        let city = destination.cityName
        let transportType = Self.transportType(for: persona)

        async let hotelsTask = loadHotels(city: city)
        async let placesTask = loadPlaces(city: city)
        async let restaurantsTask = loadRestaurants(city: city)

        let (hotels, places, restaurants) = await (hotelsTask, placesTask, restaurantsTask)

        let selectedHotel = Self.pickHotel(from: hotels, persona: persona)

        return TripStopSnapshot(
            stopNumber: stopNumber,
            departureCityName: nil,
            country: destination.country,
            cityName: city,
            travelerCount: travelerCount,
            startDate: startDate,
            endDate: endDate,
            transportType: transportType,
            hotels: hotels,
            selectedHotelIDs: Set([selectedHotel?.id].compactMap { $0 }),
            places: places,
            selectedPlaceIDs: Set(Self.pickPlaces(from: places, persona: persona).map(\.id)),
            restaurants: restaurants,
            selectedRestaurantIDs: Set(Self.pickRestaurants(from: restaurants, persona: persona).map(\.id))
        )
    }

    // MARK: - Fetching

    private func loadHotels(city: String) async -> [Hotel] {
        (try? await hotelService.fetchHotels(city: city)) ?? []
    }

    private func loadPlaces(city: String) async -> [Place] {
        (try? await placeService.fetchPlaces(city: city)) ?? []
    }

    private func loadRestaurants(city: String) async -> [Restaurant] {
        (try? await restaurantService.fetchRestaurants(city: city)) ?? []
    }

    // MARK: - Persona Rules

    /// How long a trip should run for this traveler — fast-paced travelers want short and
    /// dense, comfort-driven travelers want long and unhurried.
    static func recommendedNights(for persona: TravelPersona) -> Int {
        if persona.score(for: .pace) >= 70 { return 3 }
        if persona.score(for: .comfort) >= 70 { return 6 }
        return 4
    }

    static func transportType(for persona: TravelPersona) -> TransportType {
        persona.score(for: .adventure) > persona.score(for: .comfort) + 15 ? .car : .airplane
    }

    private static func pickHotel(from hotels: [Hotel], persona: TravelPersona) -> Hotel? {
        let comfort = persona.score(for: .comfort)
        if comfort >= 60 {
            return hotels.max { $0.pricePerNight < $1.pricePerNight }
        }
        if comfort <= 35 {
            return hotels.min { $0.pricePerNight < $1.pricePerNight }
        }
        return hotels.max { $0.rating < $1.rating }
    }

    private static func pickPlaces(from places: [Place], persona: TravelPersona) -> [Place] {
        let pace = persona.score(for: .pace)
        let count = pace >= 70 ? 4 : (pace >= 40 ? 3 : 2)
        return Array(places.sorted { $0.rating > $1.rating }.prefix(count))
    }

    private static func pickRestaurants(from restaurants: [Restaurant], persona: TravelPersona) -> [Restaurant] {
        let gastronomy = persona.score(for: .gastronomy)
        let count = gastronomy >= 70 ? 3 : (gastronomy >= 40 ? 2 : 1)
        return Array(restaurants.sorted { $0.rating > $1.rating }.prefix(count))
    }

    // MARK: - Explanation

    private func highlights(for persona: TravelPersona, destinations: [Destination], nights: Int) -> [String] {
        var highlights: [String] = []

        if let destination = destinations.first {
            let traits = destination.standoutTraits(for: persona)
            if !traits.isEmpty {
                let names = traits.map(\.title).joined(separator: ", ")
                highlights.append("\(destination.cityName), \(names.lowercased()) beklentini en iyi karşılayan rota.")
            } else {
                highlights.append("\(destination.cityName), profiline en yakın destinasyon olarak seçildi.")
            }
        }

        highlights.append(
            persona.score(for: .pace) >= 70
                ? "Hızlı temponu bildiğimiz için \(nights) gecelik yoğun bir program kurduk."
                : "Acele etmeyi sevmediğin için \(nights) geceye yayılmış rahat bir program kurduk."
        )

        let comfort = persona.score(for: .comfort)
        highlights.append(
            comfort >= 60
                ? "Konfor puanın yüksek: listedeki en iyi konaklama senin için işaretlendi."
                : (comfort <= 35
                    ? "Bütçeni koruyan en uygun konaklama senin için işaretlendi."
                    : "Fiyat/puan dengesi en iyi konaklama senin için işaretlendi.")
        )

        if persona.score(for: .gastronomy) >= 70 {
            highlights.append("Lezzet odaklı bir gezginsin, en yüksek puanlı restoranlar rotaya eklendi.")
        }

        return highlights
    }
}

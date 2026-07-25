//
//  TripSummaryViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class TripSummaryViewModel {

    // MARK: - Properties

    let stops: [TripStopSnapshot]

    var totalCost: Int {
        stops.reduce(0) { $0 + totalCost(for: $1) }
    }

    // MARK: - Init

    init(stops: [TripStopSnapshot]) {
        self.stops = stops
    }

    // MARK: - Cost Calculation

    func totalCost(for stop: TripStopSnapshot) -> Int {
        transportCost(for: stop) + hotelCost(for: stop) + placesCost(for: stop) + restaurantsCost(for: stop)
    }

    func transportCost(for stop: TripStopSnapshot) -> Int {
        guard let ticketPrice = stop.ticketPrice else { return 0 }
        return ticketPrice.minPrice * stop.travelerCount
    }

    func hotelCost(for stop: TripStopSnapshot) -> Int {
        let nights = nightsCount(for: stop)
        guard nights > 0 else { return 0 }

        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        if !selectedHotels.isEmpty {
            let nightlyTotal = selectedHotels.reduce(0) { $0 + $1.pricePerNight }
            return nightlyTotal * nights
        }

        guard let cheapestHotel = stop.hotels.min(by: { $0.pricePerNight < $1.pricePerNight }) else { return 0 }
        return cheapestHotel.pricePerNight * nights
    }

    func placesCost(for stop: TripStopSnapshot) -> Int {
        let selectedPlaces = stop.places.filter { stop.selectedPlaceIDs.contains($0.id) }
        let entryFeeTotal = selectedPlaces.reduce(0) { $0 + $1.entryFee }
        return entryFeeTotal * stop.travelerCount
    }

    func restaurantsCost(for stop: TripStopSnapshot) -> Int {
        let selectedRestaurants = stop.restaurants.filter { stop.selectedRestaurantIDs.contains($0.id) }
        let averageTotal = selectedRestaurants.reduce(0) { $0 + $1.averagePricePerPerson }
        return averageTotal * stop.travelerCount
    }

    func nightsCount(for stop: TripStopSnapshot) -> Int {
        guard let startDate = stop.startDate, let endDate = stop.endDate else { return 0 }
        return max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0, 0)
    }
}

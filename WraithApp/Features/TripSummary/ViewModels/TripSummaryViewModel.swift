//
//  TripSummaryViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class TripSummaryViewModel {

    /// Where the summary being displayed came from: a fully-built itinerary saved through
    /// Trip Creation, or a Home card the user is browsing that hasn't been saved yet.
    enum Source {
        case savedTrip(SavedTrip)
        case browsedPreview(BrowsedTripPreview)
    }

    // MARK: - Properties

    private(set) var source: Source

    /// Non-nil whenever a persisted `SavedTrip` backs this screen — a browsed-but-unsaved
    /// preview has no id yet, so anything requiring one (e.g. publishing) needs this.
    var savedTrip: SavedTrip? {
        switch source {
        case .savedTrip(let trip): return trip
        case .browsedPreview: return nil
        }
    }

    /// Present for a Home-originated trip whether or not it's been saved yet, so the
    /// hero header can render the same info the user saw on the card.
    var browsedTripPreview: BrowsedTripPreview? {
        switch source {
        case .savedTrip(let trip): return trip.browsedTripPreview
        case .browsedPreview(let preview): return preview
        }
    }

    /// True only for a browsed trip that hasn't been persisted yet — once saved (or if it
    /// was a Trip Creation itinerary all along) there's nothing left to save.
    var canSaveBrowsedTrip: Bool {
        if case .browsedPreview = source { return true }
        return false
    }

    var isPublic: Bool { savedTrip?.isPublic ?? false }

    var stops: [TripStopSnapshot] { savedTrip?.stops ?? [] }

    var totalCost: Int {
        stops.reduce(0) { $0 + totalCost(for: $1) }
    }

    // MARK: - Init

    init(source: Source) {
        self.source = source
    }

    convenience init(trip: SavedTrip) {
        self.init(source: .savedTrip(trip))
    }

    convenience init(browsedTripPreview: BrowsedTripPreview) {
        self.init(source: .browsedPreview(browsedTripPreview))
    }

    // MARK: - Public

    /// Persists a browsed-but-unsaved preview into "Seyahatlerim". Returns `nil` (and does
    /// nothing) if this screen is already backed by a saved trip.
    @discardableResult
    func saveBrowsedTrip() -> SavedTrip? {
        guard case .browsedPreview(let preview) = source else { return nil }
        let savedTrip = SavedTrip(browsedTripPreview: preview)
        TripStore.shared.save(savedTrip)
        source = .savedTrip(savedTrip)
        return savedTrip
    }

    /// Flips `isPublic` on the underlying saved trip and persists it. Returns `nil` (and
    /// does nothing) if this screen isn't backed by a persisted trip yet.
    @discardableResult
    func setPublic(_ isPublic: Bool) -> SavedTrip? {
        guard let trip = savedTrip else { return nil }
        let updatedTrip = SavedTrip(
            id: trip.id,
            createdAt: trip.createdAt,
            stops: trip.stops,
            browsedTripPreview: trip.browsedTripPreview,
            isPublic: isPublic
        )
        TripStore.shared.save(updatedTrip)
        source = .savedTrip(updatedTrip)
        return updatedTrip
    }

    // MARK: - Cost Calculation

    func totalCost(for stop: TripStopSnapshot) -> Int {
        hotelCost(for: stop) + placesCost(for: stop) + restaurantsCost(for: stop)
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

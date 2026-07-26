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

    var isPurchased: Bool { savedTrip?.isPurchased ?? false }

    var hasPurchasedPlanAddOn: Bool { savedTrip?.hasPurchasedPlanAddOn ?? false }

    /// Saved trips carry their stops directly; a browsed-but-unsaved public trip carries them
    /// on its `BrowsedTripPreview` instead — either way, this is the full stop list to render.
    var stops: [TripStopSnapshot] {
        switch source {
        case .savedTrip(let trip): return trip.stops
        case .browsedPreview(let preview): return preview.stops
        }
    }

    /// Prefers the AI-estimated total from `/ai/trip-planning` (the same figure the generated
    /// PDF shows) so this screen never disagrees with the PDF — falls back to the locally
    /// computed sum only when no plan has been generated yet.
    var totalCost: Int {
        if let amount = savedTrip?.estimatedTotalCostAmount {
            return Int(amount.rounded())
        }
        return stops.reduce(0) { $0 + totalCost(for: $1) }
    }

    /// The generated trip-plan PDF's location on disk, if one was produced and the file
    /// still exists — `nil` hides the "Detaylı Gezi Planı" button.
    var tripPlanPDFURL: URL? {
        guard let fileName = savedTrip?.tripPlanPDFFileName else { return nil }
        let url = TripPlanFileStore.fileURL(for: fileName)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
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
        let savedTrip = SavedTrip(stops: preview.stops, browsedTripPreview: preview)
        TripStore.shared.save(savedTrip)
        source = .savedTrip(savedTrip)
        return savedTrip
    }

    /// Flips `isPublic` on the underlying saved trip and persists it. Returns `nil` (and
    /// does nothing) if this screen isn't backed by a persisted trip yet.
    @discardableResult
    func setPublic(_ isPublic: Bool) -> SavedTrip? {
        guard var trip = savedTrip else { return nil }
        trip.isPublic = isPublic
        TripStore.shared.save(trip)
        source = .savedTrip(trip)
        return trip
    }

    /// Locks in whichever hotel is currently selected for one stop — Trip Summary only ever
    /// allows a single choice per stop, unlike Trip Creation's multi-select.
    @discardableResult
    func selectHotel(_ hotelID: String, forStopNumber stopNumber: Int) -> SavedTrip? {
        guard var trip = savedTrip, let index = trip.stops.firstIndex(where: { $0.stopNumber == stopNumber }) else { return nil }
        trip.stops[index].selectedHotelIDs = [hotelID]
        TripStore.shared.save(trip)
        source = .savedTrip(trip)
        return trip
    }

    /// Finalizes checkout: marks the trip purchased (each stop's currently-selected hotel
    /// becomes "the" hotel from here on) and, if chosen, the 59.90 TL detailed-plan add-on.
    @discardableResult
    func completePurchase(includingPlanAddOn: Bool) -> SavedTrip? {
        guard var trip = savedTrip else { return nil }
        // Locks each stop to whichever hotel `primaryHotel(for:)` currently resolves to, even
        // for stops the traveler never actually tapped a hotel card on — otherwise a stop
        // left with Trip Creation's original multi-selection would purchase every one of
        // those hotels instead of just the one shown/costed on this screen.
        for index in trip.stops.indices {
            guard let hotel = primaryHotel(for: trip.stops[index]) else { continue }
            trip.stops[index].selectedHotelIDs = [hotel.id]
        }
        trip.isPurchased = true
        if includingPlanAddOn { trip.hasPurchasedPlanAddOn = true }
        TripStore.shared.save(trip)
        source = .savedTrip(trip)
        return trip
    }

    /// Buys the detailed-plan add-on after the fact (the trip was already purchased without
    /// it) — same effect as opting in during checkout.
    @discardableResult
    func purchasePlanAddOn() -> SavedTrip? {
        guard var trip = savedTrip else { return nil }
        trip.hasPurchasedPlanAddOn = true
        TripStore.shared.save(trip)
        source = .savedTrip(trip)
        return trip
    }

    /// The backend only learns about a trip once it's been created via `POST /trips` — this
    /// happens lazily, the first time the user tries to publish, and the returned id is cached
    /// on the trip so later publish/unpublish calls (and re-publishing after edits) reuse it.
    func ensureBackendTripId(using publishingService: TripPublishingServiceProtocol) async throws -> String {
        guard var trip = savedTrip else { throw TripPublishingError.missingTrip }
        if let backendTripId = trip.backendTripId { return backendTripId }

        let backendTripId = try await publishingService.createTrip(trip)
        trip.backendTripId = backendTripId
        TripStore.shared.save(trip)
        source = .savedTrip(trip)
        return backendTripId
    }

    /// Generates the detailed trip-plan PDF for the currently saved trip and persists the
    /// result. Only callable once the trip has actually been saved — a browsed-but-unsaved
    /// preview has no id/stops to generate a plan from.
    func generateDetailedPlan() async throws {
        guard let trip = savedTrip else { return }
        let result = try await TripPlanningService().generatePlanPDF(for: trip)
        var updatedTrip = trip
        updatedTrip.tripPlanPDFFileName = result.fileName
        updatedTrip.estimatedTotalCostAmount = result.totalEstimatedCost.amount
        updatedTrip.estimatedTotalCostCurrency = result.totalEstimatedCost.currency
        TripStore.shared.save(updatedTrip)
        source = .savedTrip(updatedTrip)
    }

    // MARK: - Cost Calculation

    /// The ticket's mock fare plus the chosen hotel's full stay total — deliberately just
    /// these two (not places/restaurants), matching what's actually shown/purchased on this
    /// screen: a flight and a room, nothing per-activity is billed here.
    func totalCost(for stop: TripStopSnapshot) -> Int {
        ticketCost(for: stop) + hotelCost(for: stop)
    }

    /// A flat mock fare (e.g. 2250 TL for a flight) — not multiplied by traveler count, same
    /// as the hotel's nightly rate isn't either.
    func ticketCost(for stop: TripStopSnapshot) -> Int {
        stop.transportType.mockMinimumTicketPrice
    }

    func hotelCost(for stop: TripStopSnapshot) -> Int {
        let nights = nightsCount(for: stop)
        guard nights > 0, let hotel = primaryHotel(for: stop) else { return 0 }
        return hotel.pricePerNight * nights
    }

    /// Trip Summary only ever bills for a single hotel per stop, even though `selectedHotelIDs`
    /// can still hold more than one entry left over from Trip Creation's multi-select — the
    /// cheapest of whatever's selected (deterministic, unlike `Set.first`) is "the" hotel until
    /// the traveler taps a different one. Falls back to the cheapest option overall when
    /// nothing's selected yet.
    func primaryHotel(for stop: TripStopSnapshot) -> Hotel? {
        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        if let cheapestSelected = selectedHotels.min(by: { $0.pricePerNight < $1.pricePerNight }) {
            return cheapestSelected
        }
        return stop.hotels.min(by: { $0.pricePerNight < $1.pricePerNight })
    }

    func nightsCount(for stop: TripStopSnapshot) -> Int {
        guard let startDate = stop.startDate, let endDate = stop.endDate else { return 0 }
        return max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0, 0)
    }
}

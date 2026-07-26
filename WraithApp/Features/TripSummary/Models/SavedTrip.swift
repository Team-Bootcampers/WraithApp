//
//  SavedTrip.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct SavedTrip: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    var stops: [TripStopSnapshot]
    /// Set only when this trip came from browsing a Home card rather than the Trip
    /// Creation flow — `stops` is still populated for these (Home cards carry their own
    /// itinerary), just alongside the extra marketing info (image, rating, price...).
    let browsedTripPreview: BrowsedTripPreview?
    /// True once the trip has been made visible to other users via "Herkese Aç".
    var isPublic: Bool
    /// The backend's `id` for this trip, set once it's been created there via `POST /trips`.
    /// `id` above stays purely local (used for on-device storage/lookup) since it exists
    /// before the trip is ever synced to the backend.
    var backendTripId: String?
    /// Filename (not full path — the Documents directory can change between launches) of the
    /// detailed trip-plan PDF generated from `/ai/trip-planning`, if generation succeeded.
    var tripPlanPDFFileName: String?
    /// The same `totalEstimatedCost` the generated PDF shows — kept alongside it so the
    /// Trip Summary screen never displays a different total than the PDF does.
    var estimatedTotalCostAmount: Double?
    var estimatedTotalCostCurrency: String?
    /// True once "Öde ve Tamamla" has been confirmed — locks each stop's hotel choice in and
    /// switches Trip Summary from "pick your options" to "here's what you bought".
    var isPurchased: Bool
    /// True once the 59.90 TL detailed-plan add-on has been bought, either during checkout or
    /// afterward — gates whether the bottom button generates/opens the plan for free or still
    /// asks for payment.
    var hasPurchasedPlanAddOn: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        stops: [TripStopSnapshot] = [],
        browsedTripPreview: BrowsedTripPreview? = nil,
        isPublic: Bool = false,
        backendTripId: String? = nil,
        tripPlanPDFFileName: String? = nil,
        estimatedTotalCostAmount: Double? = nil,
        estimatedTotalCostCurrency: String? = nil,
        isPurchased: Bool = false,
        hasPurchasedPlanAddOn: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.stops = stops
        self.browsedTripPreview = browsedTripPreview
        self.isPublic = isPublic
        self.backendTripId = backendTripId
        self.tripPlanPDFFileName = tripPlanPDFFileName
        self.estimatedTotalCostAmount = estimatedTotalCostAmount
        self.estimatedTotalCostCurrency = estimatedTotalCostCurrency
        self.isPurchased = isPurchased
        self.hasPurchasedPlanAddOn = hasPurchasedPlanAddOn
    }
}

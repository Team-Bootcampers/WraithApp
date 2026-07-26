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
    let stops: [TripStopSnapshot]
    /// Set only when this trip came from browsing a Home card rather than the Trip
    /// Creation flow — `stops` stays empty for those, since there's no itinerary yet.
    let browsedTripPreview: BrowsedTripPreview?
    /// True once the trip has been made visible to other users via "Herkese Aç".
    let isPublic: Bool
    /// Filename (not full path — the Documents directory can change between launches) of the
    /// detailed trip-plan PDF generated from `/ai/trip-planning`, if generation succeeded.
    var tripPlanPDFFileName: String?
    /// The same `totalEstimatedCost` the generated PDF shows — kept alongside it so the
    /// Trip Summary screen never displays a different total than the PDF does.
    var estimatedTotalCostAmount: Double?
    var estimatedTotalCostCurrency: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        stops: [TripStopSnapshot] = [],
        browsedTripPreview: BrowsedTripPreview? = nil,
        isPublic: Bool = false,
        tripPlanPDFFileName: String? = nil,
        estimatedTotalCostAmount: Double? = nil,
        estimatedTotalCostCurrency: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.stops = stops
        self.browsedTripPreview = browsedTripPreview
        self.isPublic = isPublic
        self.tripPlanPDFFileName = tripPlanPDFFileName
        self.estimatedTotalCostAmount = estimatedTotalCostAmount
        self.estimatedTotalCostCurrency = estimatedTotalCostCurrency
    }
}

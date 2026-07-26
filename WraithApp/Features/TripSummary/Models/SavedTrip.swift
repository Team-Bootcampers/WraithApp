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
    /// Filename (not full path — the Documents directory can change between launches) of the
    /// detailed trip-plan PDF generated from `/ai/trip-planning`, if generation succeeded.
    var tripPlanPDFFileName: String?

    init(id: UUID = UUID(), createdAt: Date = Date(), stops: [TripStopSnapshot], tripPlanPDFFileName: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.stops = stops
        self.tripPlanPDFFileName = tripPlanPDFFileName
    }
}

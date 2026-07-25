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

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        stops: [TripStopSnapshot] = [],
        browsedTripPreview: BrowsedTripPreview? = nil,
        isPublic: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.stops = stops
        self.browsedTripPreview = browsedTripPreview
        self.isPublic = isPublic
    }
}

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

    init(id: UUID = UUID(), createdAt: Date = Date(), stops: [TripStopSnapshot]) {
        self.id = id
        self.createdAt = createdAt
        self.stops = stops
    }
}

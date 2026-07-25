//
//  ItineraryPlan.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// A ready-to-save trip generated from a traveler's persona, plus the reasoning behind it.
struct ItineraryPlan {

    let destinations: [Destination]
    let trip: SavedTrip
    let matchScore: Int
    let highlights: [String]

    var primaryDestination: Destination? {
        destinations.first
    }

    var totalCost: Int {
        TripSummaryViewModel(trip: trip).totalCost
    }
}

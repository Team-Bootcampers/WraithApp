//
//  PopularTrip.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Shaped to mirror the `GET /trips` API response, mapped from `TripListItemDto` in
/// `PopularTripsService`.
struct PopularTrip {
    let id: String
    let title: String
    let imageURL: URL?
    let rating: Double
    let reviewCount: Int
    let durationInDays: Int
    let description: String
    let price: Int
    let currency: String
    let popularityScore: Int
    var isFavorite: Bool
    /// The trip's actual stops (country/city, dates, transport, hotels/attractions/restaurants)
    /// as returned by `GET /trips` — carried through so the detail screen can show everything,
    /// not just the card summary.
    let stops: [TripStopSnapshot]

    var durationText: String {
        durationInDays == 1 ? "1 Gün" : "\(durationInDays) Gün"
    }
}

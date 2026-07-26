//
//  PopularTrip.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Shaped to mirror the eventual `GET /trips` API response so swapping
/// `MockPopularTripsService` for a real network-backed service later requires no model changes.
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

    var durationText: String {
        durationInDays == 1 ? "1 Gün" : "\(durationInDays) Gün"
    }
}

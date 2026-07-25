//
//  BrowsedTripPreview.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// A snapshot of the Home card a user tapped into (image, title, description, ...), carried
/// into the Trip Summary flow so that screen can render the same info without Home and
/// TripSummary depending on each other's feature-internal models.
struct BrowsedTripPreview: Codable {
    let id: String
    let title: String
    let description: String
    let imageURL: URL?
    let rating: Double
    let reviewCount: Int
    let durationInDays: Int
    let price: Int
    let currency: String

    var durationText: String {
        durationInDays == 1 ? "1 Gün" : "\(durationInDays) Gün"
    }
}

//
//  PopularTripsServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Backs Home's trip list. `query` is applied client-side (the backend has no free-text
/// search); `sortOption` maps to `GET /trips`'s `popular`/`personalized` flags where the
/// backend supports server-side sorting, and is applied client-side otherwise.
protocol PopularTripsServiceProtocol {
    func fetchTrips(query: String?, sortOption: PopularTripSortOption) async throws -> [PopularTrip]
}

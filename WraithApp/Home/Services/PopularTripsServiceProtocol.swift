//
//  PopularTripsServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Mirrors the eventual `GET /trips?query=&sort=` endpoint — sorting and searching both
/// happen server-side, this call just asks for the result set the backend would return.
protocol PopularTripsServiceProtocol {
    func fetchTrips(query: String?, sortOption: PopularTripSortOption) async throws -> [PopularTrip]
}

//
//  TripPublishingService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Mirrors the eventual `POST /trips/{id}/publish` and `POST /trips/{id}/unpublish`
/// endpoints that toggle whether a saved trip is visible to other users.
protocol TripPublishingServiceProtocol {
    func publishTrip(tripID: UUID, title: String, description: String) async throws
    func unpublishTrip(tripID: UUID) async throws
}

final class MockTripPublishingService: TripPublishingServiceProtocol {

    func publishTrip(tripID: UUID, title: String, description: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func unpublishTrip(tripID: UUID) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}

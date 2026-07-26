//
//  TripSyncAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Full trip shape now required on `POST /trips` (previously a slimmer `userId/stops/isPublic`
/// body) — the backend echoes this same shape back on `GET /trips`, with `id` (and
/// `stopCount`/`viewCount`/etc.) server-assigned. `id` is intentionally omitted here: sending
/// a client-generated id on create made the server treat it as an update of a non-existent
/// row and silently no-op instead of inserting.
struct SyncTripRequestDto: Encodable {
    let userId: String
    let stopCount: Int
    let stops: [SyncTripStopDto]
    let isPublic: Bool
    let title: String
    let description: String
    let coverImage: String
    let durationDays: Int
    let viewCount: Int
    let ratingAverage: Double
    let ratingCount: Int
    let createdAt: String
    let updatedAt: String
}

/// Shared by both directions: sent as part of `SyncTripRequestDto` on `POST /trips`, and
/// decoded back out of `GET /trips` — the backend echoes the same stop shape it was given.
struct SyncTripStopDto: Codable {
    let stopNumber: Int
    let country: String
    let cityName: String
    let startDate: String
    let endDate: String
    let personCount: Int
    let transportType: String
    let totalCost: SyncTripCostDto
    let hotels: [SyncTripPlaceDto]
    let attractions: [SyncTripPlaceDto]
    let restaurants: [SyncTripPlaceDto]
}

struct SyncTripCostDto: Codable {
    let amount: Int
    let currency: String
}

struct SyncTripPriceDto: Codable {
    let amount: Int
    let currency: String
    let period: String
}

/// Unified shape now shared by hotels, attractions and restaurants alike.
struct SyncTripPlaceDto: Codable {
    let id: String
    let name: String
    let rating: Double
    let address: String
    let price: SyncTripPriceDto
    let images: [String]
    let country: String
    let cityName: String
}

/// `GET /trips` returns an array of these — mirrors `SyncTripRequestDto` plus the fields the
/// server maintains itself (`stopCount`, `viewCount`, timestamps, ...).
struct SyncTripResponseDto: Decodable {
    let id: String
    let userId: String
    let stopCount: Int
    let stops: [SyncTripStopDto]
    let isPublic: Bool
    let title: String
    let description: String
    let coverImage: String
    let durationDays: Int
    let viewCount: Int
    let ratingAverage: Double
    let ratingCount: Int
    let createdAt: String
    let updatedAt: String
}

/// Wraps `POST /trips` and `GET /trips` — pushes a locally-saved trip (all stops, with full
/// detail) up to the backend under the now-authenticated user's id, and later pulls that
/// user's trips back down by id.
enum TripSyncAPI {

    static func syncTrip(_ request: SyncTripRequestDto, token: String?) async throws {
        try await APIClient.shared.requestNoContent(
            path: "/trips",
            method: "POST",
            body: request,
            authToken: token
        )
    }

    static func fetchTrips(userId: String, token: String?) async throws -> [SyncTripResponseDto] {
        let encodedUserId = userId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? userId
        return try await APIClient.shared.request(
            path: "/trips?userId=\(encodedUserId)",
            method: "GET",
            authToken: token
        )
    }
}

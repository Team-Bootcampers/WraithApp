//
//  TripPublishingAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

private struct PublishTripRequestDto: Encodable {
    let title: String
    let description: String
}

private struct PublishTripResponseDto: Decodable {
    let id: String
}

/// Wraps `POST /trips/{id}/publish` and `POST /trips/{id}/unpublish` from the
/// CoreBackendKit API.
enum TripPublishingAPI {

    static func publishTrip(id: String, title: String, description: String, token: String?) async throws {
        let _: PublishTripResponseDto = try await APIClient.shared.request(
            path: "/trips/\(id)/publish",
            method: "POST",
            body: PublishTripRequestDto(title: title, description: description),
            authToken: token
        )
    }

    static func unpublishTrip(id: String, token: String?) async throws {
        try await APIClient.shared.requestNoContent(
            path: "/trips/\(id)/unpublish",
            method: "POST",
            authToken: token
        )
    }
}

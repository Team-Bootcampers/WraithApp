//
//  TripAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct CreateTripRequestDto: Encodable {
    let userId: String
    let stops: [CreateTripStopDto]
    let isPublic: Bool
}

struct CreateTripStopDto: Encodable {
    let stopNumber: Int
    let country: String
    let cityName: String
    let startDate: String
    let endDate: String
    let personCount: Int
    let transportType: String
    let totalCost: CreateTripCostDto
    let hotels: [CreateTripPlaceDto]
    let attractions: [CreateTripPlaceDto]
    let restaurants: [CreateTripPlaceDto]
}

struct CreateTripCostDto: Encodable {
    let amount: Double
    let currency: String
}

struct CreateTripPlaceDto: Encodable {
    let id: String
    let name: String
    let rating: Double
    let address: String
    let price: CreateTripPriceDto
    let images: [String]
    let country: String
    let cityName: String
}

struct CreateTripPriceDto: Encodable {
    let amount: Double
    let currency: String
    let period: String
}

struct CreateTripResponseDto: Decodable {
    let id: String
}

struct TripListItemDto: Decodable {
    let id: String
    let title: String
    let description: String
    let coverImage: String
    let durationDays: Int
    let viewCount: Int
    let ratingAverage: Double
    let ratingCount: Int
    let stops: [TripListItemStopDto]
}

struct TripListItemStopDto: Decodable {
    let stopNumber: Int
    let country: String
    let cityName: String
    let startDate: String
    let endDate: String
    let personCount: Int
    let transportType: String
    let totalCost: TripListItemCostDto
    let hotels: [TripListItemPlaceDto]
    let attractions: [TripListItemPlaceDto]
    let restaurants: [TripListItemPlaceDto]
}

struct TripListItemCostDto: Decodable {
    let amount: Double
    let currency: String
}

struct TripListItemPlaceDto: Decodable {
    let id: String
    let name: String
    let rating: Double
    let address: String
    let price: TripListItemPriceDto
    let images: [String]
    let country: String
    let cityName: String
}

struct TripListItemPriceDto: Decodable {
    let amount: Double
    let currency: String
    let period: String
}

/// Wraps `POST /trips` (persists a fully-built itinerary so it can later be shared via
/// `TripPublishingAPI`) and `GET /trips` (lists trips, optionally scoped by owner,
/// public/popular/personalized flags, or country/city).
enum TripAPI {

    static func createTrip(request: CreateTripRequestDto, token: String?) async throws -> CreateTripResponseDto {
        try await APIClient.shared.request(
            path: "/trips",
            method: "POST",
            body: request,
            authToken: token
        )
    }

    static func fetchTrips(
        userId: String? = nil,
        isPublic: Bool? = nil,
        popular: Bool = false,
        personalized: Bool = false,
        personalityAnalysis: String? = nil,
        country: String? = nil,
        city: String? = nil,
        token: String?
    ) async throws -> [TripListItemDto] {
        var components = URLComponents()
        components.path = "/trips"

        var queryItems: [URLQueryItem] = []
        if let userId { queryItems.append(URLQueryItem(name: "userId", value: userId)) }
        if let isPublic { queryItems.append(URLQueryItem(name: "isPublic", value: String(isPublic))) }
        if popular { queryItems.append(URLQueryItem(name: "popular", value: "true")) }
        if personalized { queryItems.append(URLQueryItem(name: "personalized", value: "true")) }
        if let personalityAnalysis { queryItems.append(URLQueryItem(name: "personalityAnalysis", value: personalityAnalysis)) }
        if let country { queryItems.append(URLQueryItem(name: "country", value: country)) }
        if let city { queryItems.append(URLQueryItem(name: "city", value: city)) }
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let path = components.string else { throw APIError.invalidURL }
        return try await APIClient.shared.request(path: path, method: "GET", authToken: token)
    }
}

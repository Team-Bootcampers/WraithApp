//
//  TripStopSnapshot.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct TripStopSnapshot: Codable {
    let stopNumber: Int
    let country: Country?
    let cityName: String?
    let travelerCount: Int
    let startDate: Date?
    let endDate: Date?
    let transportType: TransportType
    let ticketPrice: TicketPrice?
    let hotels: [Hotel]
    let selectedHotelIDs: Set<String>
    let places: [Place]
    let selectedPlaceIDs: Set<String>
    let restaurants: [Restaurant]
    let selectedRestaurantIDs: Set<String>
}

//
//  TripCreationDraft.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct TripCreationDraft {
    var travelerCount: Int = 1
    var startDate: Date?
    var endDate: Date?
    var selectedDepartureCity: City?
    var selectedCountry: Country?
    var selectedCity: City?
    var selectedTransportType: TransportType = .airplane
    var hotels: [Hotel] = []
    var selectedHotelIDs: Set<String> = []
    var places: [Place] = []
    var selectedPlaceIDs: Set<String> = []
    var restaurants: [Restaurant] = []
    var selectedRestaurantIDs: Set<String> = []
}

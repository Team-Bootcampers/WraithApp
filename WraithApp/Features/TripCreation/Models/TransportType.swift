//
//  TransportType.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum TransportType: String, CaseIterable, Equatable, Codable {
    case airplane
    case bus
    case car

    var title: String {
        switch self {
        case .airplane: return "Uçak"
        case .bus: return "Otobüs"
        case .car: return "Araba"
        }
    }

    var iconName: String {
        switch self {
        case .airplane: return "airplane"
        case .bus: return "bus"
        case .car: return "car"
        }
    }

    var departureIconName: String {
        switch self {
        case .airplane: return "airplane.departure"
        case .bus: return "bus"
        case .car: return "car.fill"
        }
    }

    /// Mock starting ticket price shown in Trip Summary and folded into "Bu Durağın
    /// Maliyeti" — there's no real fare API behind this yet.
    var mockMinimumTicketPrice: Int {
        switch self {
        case .airplane: return 2250
        case .bus: return 850
        case .car: return 450
        }
    }

    /// Shown in place of the "Bilet Seç" row once the trip is purchased, standing in for
    /// which carrier the (mock) ticket was booked with.
    var purchasedCarrierName: String {
        switch self {
        case .airplane: return "THY"
        case .bus: return "Metro Turizm"
        case .car: return "Sixt Rent A Car"
        }
    }
}

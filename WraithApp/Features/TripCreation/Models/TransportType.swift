//
//  TransportType.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum TransportType: CaseIterable, Equatable {
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
}

//
//  MockTicketPriceService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class MockTicketPriceService: TicketPriceServiceProtocol {

    private static let basePrices: [TransportType: Int] = [
        .airplane: 1250,
        .bus: 450,
        .car: 600
    ]

    func fetchPrice(transportType: TransportType, city: String?, startDate: Date?, endDate: Date?) async throws -> TicketPrice {
        try await Task.sleep(nanoseconds: 500_000_000)
        let minPrice = Self.basePrices[transportType] ?? 500
        return TicketPrice(transportType: transportType, minPrice: minPrice, currency: "TL")
    }
}

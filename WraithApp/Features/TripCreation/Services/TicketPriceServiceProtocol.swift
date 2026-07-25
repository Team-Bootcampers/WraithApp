//
//  TicketPriceServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

protocol TicketPriceServiceProtocol {
    func fetchPrice(transportType: TransportType, city: String?, startDate: Date?, endDate: Date?) async throws -> TicketPrice
}

//
//  TicketPriceModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct TicketPrice: Equatable {
    let transportType: TransportType
    let minPrice: Int
    let currency: String
}

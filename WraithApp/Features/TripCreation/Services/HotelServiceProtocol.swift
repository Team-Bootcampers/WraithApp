//
//  HotelServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

protocol HotelServiceProtocol {
    func fetchHotels(city: String) async throws -> [Hotel]
}

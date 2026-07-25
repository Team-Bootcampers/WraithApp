//
//  PlaceServiceProtocol.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

protocol PlaceServiceProtocol {
    func fetchPlaces(city: String) async throws -> [Place]
}

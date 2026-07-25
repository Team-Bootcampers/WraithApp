//
//  CountryCityModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct Country: Equatable {
    let name: String
    let iso2: String
    let flagURL: URL?
}

struct City: Equatable {
    let name: String
}

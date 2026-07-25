//
//  CountryCityService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation
import NetworkManager

protocol CountryCityServiceProtocol {
    func fetchCountries() async throws -> [Country]
    func fetchCities(for countryName: String) async throws -> [City]
}

final class CountryCityService: CountryCityServiceProtocol {

    // MARK: - Properties

    private let networkManager: NetworkManagerProtocol
    private var cachedCountries: [Country]?

    // MARK: - Init

    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: - CountryCityServiceProtocol

    func fetchCountries() async throws -> [Country] {
        if let cachedCountries {
            return cachedCountries
        }

        let response: FlagImagesResponse = try await networkManager.request(CountriesFlagImagesEndpoint())
        let countries = response.data
            .map { Country(name: $0.name, iso2: $0.iso2, flagURL: Self.flagURL(iso2: $0.iso2)) }
            .sorted { $0.name < $1.name }

        cachedCountries = countries
        return countries
    }

    func fetchCities(for countryName: String) async throws -> [City] {
        let response: CitiesResponse = try await networkManager.request(CountriesCitiesEndpoint(country: countryName))
        return response.data.map { City(name: $0) }
    }

    // MARK: - Helpers

    private static func flagURL(iso2: String) -> URL? {
        URL(string: "https://flagcdn.com/w80/\(iso2.lowercased()).png")
    }
}

// MARK: - Endpoints

private struct CountriesFlagImagesEndpoint: Endpoint {
    let baseURL = URL(string: "https://countriesnow.space/api/v0.1")!
    let path = "/countries/flag/images"
    let method: HTTPMethod = .get
}

private struct CountriesCitiesEndpoint: Endpoint {
    let baseURL = URL(string: "https://countriesnow.space/api/v0.1")!
    let path = "/countries/cities"
    let method: HTTPMethod = .post
    let country: String

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var body: Data? {
        try? JSONSerialization.data(withJSONObject: ["country": country])
    }
}

// MARK: - DTOs

private struct FlagImagesResponse: Decodable {
    let data: [FlagImageDTO]
}

private struct FlagImageDTO: Decodable {
    let name: String
    let iso2: String
}

private struct CitiesResponse: Decodable {
    let data: [String]
}

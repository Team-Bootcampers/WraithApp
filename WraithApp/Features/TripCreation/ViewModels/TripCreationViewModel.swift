//
//  TripCreationViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class TripCreationViewModel {

    // MARK: - Properties

    private(set) var draft = TripCreationDraft() {
        didSet { stateObservers.values.forEach { $0(draft) } }
    }

    private var stateObservers: [UUID: (TripCreationDraft) -> Void] = [:]

    private let minimumTravelerCount = 1
    private let countryCityService: CountryCityServiceProtocol
    private let hotelService: HotelServiceProtocol
    private let placeService: PlaceServiceProtocol
    private let restaurantService: RestaurantServiceProtocol

    // Selection IDs carried over from an edited stop, applied once the corresponding
    // (re-fetched) list lands — see `loadStop(from:)`.
    private var pendingHotelSelectionIDs: Set<String>?
    private var pendingPlaceSelectionIDs: Set<String>?
    private var pendingRestaurantSelectionIDs: Set<String>?

    var travelerCount: Int { draft.travelerCount }
    var startDate: Date? { draft.startDate }
    var endDate: Date? { draft.endDate }
    var selectedDepartureCity: City? { draft.selectedDepartureCity }
    var selectedCountry: Country? { draft.selectedCountry }
    var selectedCity: City? { draft.selectedCity }
    var selectedTransportType: TransportType { draft.selectedTransportType }
    var hotels: [Hotel] { draft.hotels }
    var places: [Place] { draft.places }
    var restaurants: [Restaurant] { draft.restaurants }

    var minimumReturnDate: Date {
        guard let startDate = draft.startDate else { return Date() }
        return Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
    }

    // MARK: - Init

    init(
        countryCityService: CountryCityServiceProtocol = CountryCityService(),
        hotelService: HotelServiceProtocol = MockHotelService(),
        placeService: PlaceServiceProtocol = MockPlaceService(),
        restaurantService: RestaurantServiceProtocol = RestaurantService()
    ) {
        self.countryCityService = countryCityService
        self.hotelService = hotelService
        self.placeService = placeService
        self.restaurantService = restaurantService
    }

    // MARK: - State Observation

    @discardableResult
    func addObserver(_ handler: @escaping (TripCreationDraft) -> Void) -> UUID {
        let id = UUID()
        stateObservers[id] = handler
        return id
    }

    func removeObserver(_ id: UUID) {
        stateObservers[id] = nil
    }

    // MARK: - Traveler Count

    func incrementTravelerCount() {
        draft.travelerCount += 1
    }

    func decrementTravelerCount() {
        guard draft.travelerCount > minimumTravelerCount else { return }
        draft.travelerCount -= 1
    }

    // MARK: - Date Selection

    func selectStartDate(_ date: Date) {
        draft.startDate = date
        if let endDate = draft.endDate, endDate <= date {
            draft.endDate = nil
        }
    }

    @discardableResult
    func selectEndDate(_ date: Date) -> Bool {
        guard let startDate = draft.startDate, date > startDate else { return false }
        draft.endDate = date
        return true
    }

    // MARK: - Editing

    /// Re-populates this (fresh) view model from a previously saved stop, so the "Düzenle"
    /// flow can reopen the creation screen with everything the user had chosen. Hotels/
    /// places/restaurants aren't copied directly — the city selection re-triggers the same
    /// (deterministic, mock) fetch, and the previous selection IDs are re-applied once that
    /// lands, since re-fetching also naturally validates the choices are still available.
    func loadStop(from snapshot: TripStopSnapshot) {
        pendingHotelSelectionIDs = snapshot.selectedHotelIDs
        pendingPlaceSelectionIDs = snapshot.selectedPlaceIDs
        pendingRestaurantSelectionIDs = snapshot.selectedRestaurantIDs

        if let departureCityName = snapshot.departureCityName {
            selectDepartureCity(City(name: departureCityName))
        }
        if let country = snapshot.country {
            selectCountry(country)
        }
        if let cityName = snapshot.cityName {
            selectCity(City(name: cityName))
        }

        draft.travelerCount = snapshot.travelerCount

        if let startDate = snapshot.startDate {
            selectStartDate(startDate)
        }
        if let endDate = snapshot.endDate {
            selectEndDate(endDate)
        }

        selectTransportType(snapshot.transportType)
    }

    // MARK: - Country & City

    private static let departureCountryName = "Turkey"

    func loadCountries() async throws -> [Country] {
        try await countryCityService.fetchCountries()
    }

    func loadCities(for country: Country) async throws -> [City] {
        try await countryCityService.fetchCities(for: country.name)
    }

    /// Departure is always domestic, so there's no need to make the traveler pick a
    /// departure country too — just the city, scoped to Turkey.
    func loadDepartureCities() async throws -> [City] {
        try await countryCityService.fetchCities(for: Self.departureCountryName)
    }

    func selectDepartureCity(_ city: City) {
        draft.selectedDepartureCity = city
    }

    func selectCountry(_ country: Country) {
        draft.selectedCountry = country
        draft.selectedCity = nil
        refreshHotelsIfPossible()
        refreshPlacesIfPossible()
        refreshRestaurantsIfPossible()
    }

    func selectCity(_ city: City) {
        draft.selectedCity = city
        refreshHotelsIfPossible()
        refreshPlacesIfPossible()
        refreshRestaurantsIfPossible()
    }

    // MARK: - Transport

    func selectTransportType(_ transportType: TransportType) {
        draft.selectedTransportType = transportType
    }

    // MARK: - Hotels

    private func refreshHotelsIfPossible() {
        guard let city = draft.selectedCity?.name else {
            draft.hotels = []
            draft.selectedHotelIDs = []
            return
        }

        draft.hotels = []
        draft.selectedHotelIDs = []

        Task { [weak self] in
            guard let self else { return }
            let hotels = (try? await self.hotelService.fetchHotels(city: city)) ?? []
            guard self.draft.selectedCity?.name == city else { return }
            self.draft.hotels = hotels
            if let pending = self.pendingHotelSelectionIDs {
                self.draft.selectedHotelIDs = pending.intersection(hotels.map(\.id))
                self.pendingHotelSelectionIDs = nil
            }
        }
    }

    func toggleHotelSelection(_ hotel: Hotel) {
        toggleSelection(id: hotel.id, in: &draft.selectedHotelIDs)
    }

    func isHotelSelected(_ hotel: Hotel) -> Bool {
        draft.selectedHotelIDs.contains(hotel.id)
    }

    // MARK: - Places

    private func refreshPlacesIfPossible() {
        guard let city = draft.selectedCity?.name else {
            draft.places = []
            draft.selectedPlaceIDs = []
            return
        }

        draft.places = []
        draft.selectedPlaceIDs = []

        Task { [weak self] in
            guard let self else { return }
            let places = (try? await self.placeService.fetchPlaces(city: city)) ?? []
            guard self.draft.selectedCity?.name == city else { return }
            self.draft.places = places
            if let pending = self.pendingPlaceSelectionIDs {
                self.draft.selectedPlaceIDs = pending.intersection(places.map(\.id))
                self.pendingPlaceSelectionIDs = nil
            }
        }
    }

    func togglePlaceSelection(_ place: Place) {
        toggleSelection(id: place.id, in: &draft.selectedPlaceIDs)
    }

    func isPlaceSelected(_ place: Place) -> Bool {
        draft.selectedPlaceIDs.contains(place.id)
    }

    // MARK: - Restaurants

    private func refreshRestaurantsIfPossible() {
        draft.restaurants = []
        draft.selectedRestaurantIDs = []
        draft.isLoadingRestaurants = false
        draft.restaurantsUnavailableReason = nil

        guard let country = draft.selectedCountry?.name, let city = draft.selectedCity?.name else {
            return
        }

        guard let personalityAnalysis = TravelPersonalityStore.current else {
            draft.restaurantsUnavailableReason = "Restoran önerisi için önce karakter analizini tamamlaman gerekiyor."
            return
        }

        draft.isLoadingRestaurants = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let restaurants = try await self.restaurantService.fetchRestaurants(
                    country: country,
                    city: city,
                    personalityAnalysis: personalityAnalysis
                )
                guard self.draft.selectedCity?.name == city else { return }
                self.draft.isLoadingRestaurants = false
                self.draft.restaurants = restaurants
                if restaurants.isEmpty {
                    self.draft.restaurantsUnavailableReason = "Bu şehir için restoran önerisi bulunamadı."
                }
                if let pending = self.pendingRestaurantSelectionIDs {
                    self.draft.selectedRestaurantIDs = pending.intersection(restaurants.map(\.id))
                    self.pendingRestaurantSelectionIDs = nil
                }
            } catch {
                guard self.draft.selectedCity?.name == city else { return }
                // Surfaced in the console since there's no in-app diagnostics — check here
                // first (401 → auth, decoding error → DTO/response mismatch, etc.) if this
                // still shows up as "unavailable" in the UI.
                print("⚠️ RestaurantService.fetchRestaurants failed: \(error)")
                self.draft.isLoadingRestaurants = false
                self.draft.restaurantsUnavailableReason = "Restoranlar yüklenemedi. Lütfen tekrar dene."
            }
        }
    }

    func toggleRestaurantSelection(_ restaurant: Restaurant) {
        toggleSelection(id: restaurant.id, in: &draft.selectedRestaurantIDs)
    }

    func isRestaurantSelected(_ restaurant: Restaurant) -> Bool {
        draft.selectedRestaurantIDs.contains(restaurant.id)
    }

    // MARK: - Selection Helper

    private func toggleSelection(id: String, in set: inout Set<String>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }
}

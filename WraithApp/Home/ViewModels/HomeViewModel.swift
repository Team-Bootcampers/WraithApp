//
//  HomeViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class HomeViewModel {

    // MARK: - Properties

    private(set) var trips: [PopularTrip] = []
    private(set) var sortOption: PopularTripSortOption = .popularity
    private(set) var isLoading = false

    var onStateChange: (() -> Void)?
    var onFavoriteToggled: ((String) -> Void)?

    private let service: PopularTripsServiceProtocol
    private var activeQuery: String?
    private var loadTask: Task<Void, Never>?
    private var searchDebounceTask: Task<Void, Never>?
    /// The mock/backend always reports `isFavorite: false`, so favorite state has to be
    /// tracked locally and re-applied to every freshly fetched list — otherwise a toggle
    /// gets silently wiped out the next time `refresh()` runs (e.g. after a sort change).
    private var favoriteTripIDs: Set<String> = []

    private static let minimumSearchLength = 3
    private static let searchDebounceNanoseconds: UInt64 = 450_000_000

    // MARK: - Init

    init(service: PopularTripsServiceProtocol = MockPopularTripsService()) {
        self.service = service
    }

    // MARK: - Public

    func start() {
        refresh()
    }

    /// Re-sorts the already-loaded trips locally and nothing else — the data is already on
    /// screen, so a mere re-sort has no reason to round-trip through `refresh()`. Doing so
    /// used to cause a visible re-shuffle a moment later, since the (mock) backend's own
    /// unstable sort can break rating/price ties differently than the local sort just did.
    func selectSortOption(_ option: PopularTripSortOption) {
        guard sortOption != option else { return }
        sortOption = option
        sortTripsLocally()
        onStateChange?()
    }

    /// Debounces so a network call isn't fired on every keystroke, cancels any in-flight
    /// search when newer input arrives, and only searches once there's enough text to make
    /// a meaningful query — below that it just falls back to the unfiltered list.
    func searchTextDidChange(_ text: String) {
        searchDebounceTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= Self.minimumSearchLength else {
            guard activeQuery != nil else { return }
            activeQuery = nil
            refresh()
            return
        }

        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.searchDebounceNanoseconds)
            guard !Task.isCancelled, let self else { return }
            self.activeQuery = trimmed
            self.refresh()
        }
    }

    /// Deliberately does not go through `onStateChange` (which triggers a full list reload) —
    /// only the tapped card's visual state should change, so this fires a dedicated,
    /// single-row-scoped callback instead.
    func toggleFavorite(for trip: PopularTrip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[index].isFavorite.toggle()

        if trips[index].isFavorite {
            favoriteTripIDs.insert(trip.id)
        } else {
            favoriteTripIDs.remove(trip.id)
        }

        onFavoriteToggled?(trip.id)
    }

    // MARK: - Private

    private func sortTripsLocally() {
        switch sortOption {
        case .popularity:
            trips.sort { $0.popularityScore > $1.popularityScore }
        case .price:
            trips.sort { $0.price < $1.price }
        case .rating:
            trips.sort { $0.rating > $1.rating }
        case .personalized:
            // No real recommendation signal yet, so favorited trips are surfaced first and
            // the rest falls back to popularity — a placeholder until the API exposes an
            // actual personalization score.
            trips.sort {
                if $0.isFavorite != $1.isFavorite { return $0.isFavorite }
                return $0.popularityScore > $1.popularityScore
            }
        }
    }

    private func refresh() {
        loadTask?.cancel()
        // Only notify immediately when a loading spinner actually needs to appear (first
        // load, nothing on screen yet). When refining a search with results already
        // visible, this used to fire an extra `onStateChange` — and therefore an extra
        // `tableView.reloadData()` — with the same, not-yet-updated list, before the real
        // one landed a moment later. That's what made each search feel like it "reloaded
        // twice" per commit.
        isLoading = trips.isEmpty
        if isLoading {
            onStateChange?()
        }

        let query = activeQuery
        let sortOption = sortOption

        loadTask = Task { [weak self] in
            let trips = (try? await self?.service.fetchTrips(query: query, sortOption: sortOption)) ?? []
            guard !Task.isCancelled, let self else { return }
            self.trips = trips.map { trip in
                var trip = trip
                trip.isFavorite = self.favoriteTripIDs.contains(trip.id)
                return trip
            }
            self.isLoading = false
            self.onStateChange?()
        }
    }
}

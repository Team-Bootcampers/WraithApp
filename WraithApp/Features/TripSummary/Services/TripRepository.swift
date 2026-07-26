//
//  TripRepository.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// The single place the app should go through to read or write "the user's trips" — hides
/// whether that means the local guest store or the backend behind login state. Guests read
/// and write `TripStore` directly; once logged in, everything routes through the API instead
/// (login/signup already does a one-time migration of whatever was saved locally, via
/// `TripSyncService.syncAllSavedTrips()`).
final class TripRepository {

    static let shared = TripRepository()

    private let syncService = TripSyncService()

    private init() {}

    func loadTrips() async -> [SavedTrip] {
        guard UserSession.shared.isLoggedIn else {
            return TripStore.shared.loadTrips()
        }

        do {
            return try await syncService.fetchRemoteTrips()
        } catch {
            // Network hiccup: fall back to whatever's cached locally rather than showing
            // an empty list.
            return TripStore.shared.loadTrips()
        }
    }

    /// Persists a trip that doesn't exist on the backend yet — the only case that should
    /// ever call `POST /trips`. Used by Trip Creation and by anything else that saves a
    /// brand-new `SavedTrip` for the first time (a browsed Home-card trip, a Surprise Trip
    /// plan, ...).
    func create(_ trip: SavedTrip) async {
        guard UserSession.shared.isLoggedIn else {
            TripStore.shared.save(trip)
            return
        }

        do {
            try await syncService.push(trip)
        } catch {
            print("❌ [TripRepository] Failed to sync trip to backend, keeping local copy: \(error)")
            // Best-effort: keep a local copy so the trip isn't lost if the POST fails.
            TripStore.shared.save(trip)
        }
    }

    /// Persists a change to a trip that's already been saved (e.g. toggling "Herkese Aç").
    /// The backend only exposes `POST /trips` right now, which inserts a new row rather than
    /// updating one — calling it here would silently create a duplicate trip. Until a real
    /// update endpoint exists, this stays local-only (best effort) for logged-in users.
    func update(_ trip: SavedTrip) async {
        TripStore.shared.save(trip)
    }
}

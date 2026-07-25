//
//  TripStore.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Persists the user's saved trips (built from TripCreation) so "Seyahatlerim" can list them.
final class TripStore {

    static let shared = TripStore()

    private enum Keys {
        static let trips = "com.voya.savedTrips"
    }

    private init() {}

    /// Inserts a new trip, or overwrites the existing one in place if `trip.id` already
    /// exists — otherwise editing a saved trip would leave the original untouched and add
    /// a duplicate alongside it instead of updating it.
    func save(_ trip: SavedTrip) {
        var trips = loadTrips()
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        } else {
            trips.insert(trip, at: 0)
        }
        persist(trips)
    }

    func loadTrips() -> [SavedTrip] {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.trips),
            let trips = try? JSONDecoder().decode([SavedTrip].self, from: data)
        else {
            return []
        }
        return trips
    }

    func remove(_ tripID: UUID) {
        let trips = loadTrips().filter { $0.id != tripID }
        persist(trips)
    }

    private func persist(_ trips: [SavedTrip]) {
        guard let data = try? JSONEncoder().encode(trips) else { return }
        UserDefaults.standard.set(data, forKey: Keys.trips)
    }
}

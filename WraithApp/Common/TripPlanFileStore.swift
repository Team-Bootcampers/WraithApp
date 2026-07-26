//
//  TripPlanFileStore.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Shared file-path helper for generated trip-plan PDFs — written by `TripPlanningService`,
/// read by `TripSummaryViewModel`, deleted by `TripStore` when a trip is removed.
enum TripPlanFileStore {

    static func fileURL(for fileName: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: fileURL(for: fileName))
    }
}

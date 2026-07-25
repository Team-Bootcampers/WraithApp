//
//  TicketSearchURLBuilder.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Builds a deep link into a real, public ticket-search site for the chosen transport type,
/// so tapping the price row takes the traveler somewhere they can actually buy a ticket
/// instead of a mock in-app screen.
enum TicketSearchURLBuilder {

    static func url(
        for transportType: TransportType,
        departureCity: String,
        destinationCity: String,
        date: Date
    ) -> URL? {
        switch transportType {
        case .airplane:
            return flightSearchURL(departureCity: departureCity, destinationCity: destinationCity, date: date)
        case .bus:
            return busSearchURL(departureCity: departureCity, destinationCity: destinationCity, date: date)
        case .car:
            return drivingDirectionsURL(departureCity: departureCity, destinationCity: destinationCity)
        }
    }

    // MARK: - Airplane

    private static func flightSearchURL(departureCity: String, destinationCity: String, date: Date) -> URL? {
        let query = "Flights to \(destinationCity) from \(departureCity) on \(isoDateFormatter.string(from: date))"
        var components = URLComponents(string: "https://www.google.com/travel/flights")
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        return components?.url
    }

    // MARK: - Bus

    /// A direct deep link into a specific bus operator's site (e.g. Obilet) turned out to be
    /// unreliable — route/param formats aren't publicly documented and broke in practice. A
    /// Google Search query is guaranteed to resolve (it's just the search homepage) and
    /// surfaces the real ticket sites for that route as the top results.
    private static func busSearchURL(departureCity: String, destinationCity: String, date: Date) -> URL? {
        let query = "\(departureCity) \(destinationCity) otobüs bileti \(turkishDateFormatter.string(from: date))"
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        return components?.url
    }

    // MARK: - Car

    private static func drivingDirectionsURL(departureCity: String, destinationCity: String) -> URL? {
        URL(string: "https://www.google.com/maps/dir/\(slug(departureCity))/\(slug(destinationCity))")
    }

    // MARK: - Formatting

    private static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let turkishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    /// Turkish letters don't reliably fold via `.diacriticInsensitive` (e.g. dotless "ı"
    /// isn't a composed accent), so they're mapped explicitly before falling back to
    /// diacritic folding for anything else.
    private static let turkishCharacterMap: [Character: Character] = [
        "ı": "i", "İ": "i", "I": "i",
        "ş": "s", "Ş": "s",
        "ğ": "g", "Ğ": "g",
        "ü": "u", "Ü": "u",
        "ö": "o", "Ö": "o",
        "ç": "c", "Ç": "c"
    ]

    private static func slug(_ text: String) -> String {
        let mapped = String(text.map { turkishCharacterMap[$0] ?? $0 })
        let folded = mapped.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX")).lowercased()
        let slugged = folded.map { $0.isLetter || $0.isNumber ? $0 : "-" }
        return String(slugged)
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")
    }
}

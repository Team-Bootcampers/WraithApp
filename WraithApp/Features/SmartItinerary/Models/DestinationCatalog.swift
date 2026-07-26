//
//  DestinationCatalog.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum DestinationCatalog {

    static let all: [Destination] = [
        Destination(
            cityName: "Rome",
            countryName: "Italy",
            iso2: "IT",
            tagline: "Açık hava müzesinde yaşamak",
            climateHint: "Ilıman, bol güneşli",
            travelHint: "≈2.5 saat uçuş",
            dailyBudgetPerPerson: 3500,
            affinity: [.culture: 95, .adventure: 30, .comfort: 60, .gastronomy: 85, .spontaneity: 45, .social: 60, .pace: 75]
        ),
        Destination(
            cityName: "Barcelona",
            countryName: "Spain",
            iso2: "ES",
            tagline: "Gaudí, tapas ve gece hayatı",
            climateHint: "Akdeniz iklimi, sıcak",
            travelHint: "≈3.5 saat uçuş",
            dailyBudgetPerPerson: 3200,
            affinity: [.culture: 80, .adventure: 45, .comfort: 65, .gastronomy: 85, .spontaneity: 60, .social: 90, .pace: 70]
        ),
        Destination(
            cityName: "Nevsehir",
            countryName: "Turkey",
            iso2: "TR",
            tagline: "Peribacaları ve gün doğumunda balonlar",
            climateHint: "Karasal, serin geceler",
            travelHint: "≈1.5 saat uçuş",
            dailyBudgetPerPerson: 1800,
            affinity: [.culture: 75, .adventure: 90, .comfort: 55, .gastronomy: 50, .spontaneity: 65, .social: 40, .pace: 60]
        ),
        Destination(
            cityName: "Antalya",
            countryName: "Turkey",
            iso2: "TR",
            tagline: "Turkuaz koylar ve antik patikalar",
            climateHint: "Sıcak, deniz mevsimi uzun",
            travelHint: "≈1.5 saat uçuş",
            dailyBudgetPerPerson: 1600,
            affinity: [.culture: 40, .adventure: 80, .comfort: 65, .gastronomy: 60, .spontaneity: 70, .social: 50, .pace: 35]
        ),
        Destination(
            cityName: "Prague",
            countryName: "Czech Republic",
            iso2: "CZ",
            tagline: "Masal şehrinde yürüyüş",
            climateHint: "Serin, dört mevsim",
            travelHint: "≈2.5 saat uçuş",
            dailyBudgetPerPerson: 2400,
            affinity: [.culture: 90, .adventure: 30, .comfort: 60, .gastronomy: 60, .spontaneity: 45, .social: 65, .pace: 65]
        ),
        Destination(
            cityName: "Amsterdam",
            countryName: "Netherlands",
            iso2: "NL",
            tagline: "Kanallar, bisiklet ve müzeler",
            climateHint: "Serin ve yağmurlu",
            travelHint: "≈3.5 saat uçuş",
            dailyBudgetPerPerson: 3600,
            affinity: [.culture: 75, .adventure: 40, .comfort: 65, .gastronomy: 65, .spontaneity: 60, .social: 85, .pace: 70]
        ),
        Destination(
            cityName: "Dubai",
            countryName: "United Arab Emirates",
            iso2: "AE",
            tagline: "Çölde lüksün zirvesi",
            climateHint: "Çok sıcak, kurak",
            travelHint: "≈4.5 saat uçuş",
            dailyBudgetPerPerson: 5000,
            affinity: [.culture: 40, .adventure: 45, .comfort: 98, .gastronomy: 75, .spontaneity: 30, .social: 70, .pace: 60]
        ),
        Destination(
            cityName: "Male",
            countryName: "Maldives",
            iso2: "MV",
            tagline: "Su üstü villada tam kopuş",
            climateHint: "Tropikal, ılık okyanus",
            travelHint: "≈9 saat uçuş",
            dailyBudgetPerPerson: 8000,
            affinity: [.culture: 20, .adventure: 40, .comfort: 95, .gastronomy: 55, .spontaneity: 25, .social: 25, .pace: 15]
        ),
        Destination(
            cityName: "Interlaken",
            countryName: "Switzerland",
            iso2: "CH",
            tagline: "Alpler'de adrenalin",
            climateHint: "Serin dağ havası",
            travelHint: "≈3 saat uçuş",
            dailyBudgetPerPerson: 5500,
            affinity: [.culture: 30, .adventure: 95, .comfort: 70, .gastronomy: 50, .spontaneity: 60, .social: 40, .pace: 70]
        ),
        Destination(
            cityName: "Tokyo",
            countryName: "Japan",
            iso2: "JP",
            tagline: "Gelenek ve gelecek aynı sokakta",
            climateHint: "Dört mevsim belirgin",
            travelHint: "≈12 saat uçuş",
            dailyBudgetPerPerson: 4500,
            affinity: [.culture: 90, .adventure: 55, .comfort: 75, .gastronomy: 95, .spontaneity: 50, .social: 70, .pace: 90]
        ),
        Destination(
            cityName: "Lisbon",
            countryName: "Portugal",
            iso2: "PT",
            tagline: "Tramvaylar, fado ve okyanus",
            climateHint: "Ilıman, güneşli",
            travelHint: "≈4.5 saat uçuş",
            dailyBudgetPerPerson: 2800,
            affinity: [.culture: 75, .adventure: 50, .comfort: 60, .gastronomy: 85, .spontaneity: 65, .social: 75, .pace: 55]
        ),
        Destination(
            cityName: "Reykjavik",
            countryName: "Iceland",
            iso2: "IS",
            tagline: "Kuzey ışıkları ve buz çölleri",
            climateHint: "Soğuk, rüzgarlı",
            travelHint: "≈6 saat uçuş",
            dailyBudgetPerPerson: 6000,
            affinity: [.culture: 45, .adventure: 95, .comfort: 60, .gastronomy: 55, .spontaneity: 70, .social: 35, .pace: 55]
        )
    ]

    /// Destinations ordered by how well they suit the traveler, best first.
    static func ranked(for persona: TravelPersona) -> [Destination] {
        all.sorted { $0.matchScore(for: persona) > $1.matchScore(for: persona) }
    }

    /// Best match whose per-person cost for the trip stays within `budgetPerPerson`.
    /// Falls back to the cheapest destination when nothing fits, so the caller always
    /// gets a suggestion rather than an empty state.
    static func bestMatch(for persona: TravelPersona, budgetPerPerson: Int?, nights: Int) -> Destination? {
        let candidates = ranked(for: persona)
        guard let budgetPerPerson else { return candidates.first }

        let affordable = candidates.filter { $0.dailyBudgetPerPerson * max(nights, 1) <= budgetPerPerson }
        return affordable.first ?? all.min { $0.dailyBudgetPerPerson < $1.dailyBudgetPerPerson }
    }
}

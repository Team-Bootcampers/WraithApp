//
//  SurpriseTripViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class SurpriseTripViewModel {

    // MARK: - Properties

    private let persona: TravelPersona
    private let planner: SmartItineraryPlanner

    private(set) var plan: ItineraryPlan?
    private(set) var isRevealed = false

    var nights: Int {
        SmartItineraryPlanner.recommendedNights(for: persona)
    }

    // MARK: - Init

    init(persona: TravelPersona, planner: SmartItineraryPlanner = SmartItineraryPlanner()) {
        self.persona = persona
        self.planner = planner
    }

    // MARK: - Surprise

    /// Picks the best-matching destination the budget allows and builds the full trip up
    /// front — the reveal is purely presentational, so the plan behind it is always real.
    @discardableResult
    func prepareSurprise(startDate: Date, travelerCount: Int, budgetPerPerson: Int?) async -> ItineraryPlan? {
        isRevealed = false

        guard let destination = DestinationCatalog.bestMatch(
            for: persona,
            budgetPerPerson: budgetPerPerson,
            nights: nights
        ) else {
            return nil
        }

        let plan = await planner.plan(
            for: persona,
            destinations: [destination],
            startDate: startDate,
            nightsPerStop: nights,
            travelerCount: travelerCount
        )
        self.plan = plan
        return plan
    }

    func reveal() {
        isRevealed = true
    }

    func save() -> SavedTrip? {
        guard let plan else { return nil }
        TripStore.shared.save(plan.trip)
        return plan.trip
    }
}

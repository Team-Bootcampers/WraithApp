//
//  TravelCompatibilityViewModel.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class TravelCompatibilityViewModel {

    enum CompareError: LocalizedError {
        case emptyCode
        case invalidCode

        var errorDescription: String? {
            switch self {
            case .emptyCode: return "Önce arkadaşının kodunu yapıştır."
            case .invalidCode: return "Bu kod okunamadı. Kodun tamamını kopyaladığından emin ol."
            }
        }
    }

    // MARK: - Properties

    private let persona: TravelPersona
    private let planner: SmartItineraryPlanner

    private(set) var result: CompatibilityResult?
    private(set) var jointPlan: ItineraryPlan?

    var myShareCode: String {
        PersonaShareCode.encode(persona)
    }

    var shareMessage: String {
        """
        Voya'daki seyahat kimliğim: \(persona.archetype.title).
        Ne kadar uyumlu seyahat ettiğimizi ölçmek için kodumu uygulamaya yapıştır:

        \(myShareCode)
        """
    }

    // MARK: - Init

    init(persona: TravelPersona, planner: SmartItineraryPlanner = SmartItineraryPlanner()) {
        self.persona = persona
        self.planner = planner
    }

    // MARK: - Comparison

    func compare(with code: String) -> Result<CompatibilityResult, CompareError> {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.emptyCode) }
        guard let theirs = PersonaShareCode.decode(trimmed) else { return .failure(.invalidCode) }

        let result = TravelCompatibilityCalculator.compare(mine: persona, theirs: theirs)
        self.result = result
        self.jointPlan = nil
        return .success(result)
    }

    // MARK: - Joint Trip

    /// Plans against the blended persona so the resulting trip suits both travelers rather
    /// than just the one holding the phone.
    @discardableResult
    func generateJointPlan(startDate: Date, travelerCount: Int) async -> ItineraryPlan? {
        guard let result, let destination = result.suggestedDestination else { return nil }

        let plan = await planner.plan(
            for: result.blendedPersona,
            destinations: [destination],
            startDate: startDate,
            nightsPerStop: SmartItineraryPlanner.recommendedNights(for: result.blendedPersona),
            travelerCount: travelerCount
        )
        jointPlan = plan
        return plan
    }

    func save() -> SavedTrip? {
        guard let jointPlan else { return nil }
        TripStore.shared.save(jointPlan.trip)
        return jointPlan.trip
    }
}

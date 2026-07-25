//
//  OnboardingMapper.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Converts the locally-stored quiz answers into the backend's `OnboardingAnswersDto`.
/// Relies on the questions in `CharacterAnalysisQuestions.all` keeping their fixed order,
/// since each question index (1-based, per `CharacterAnalysisCoordinator`) maps to exactly
/// one backend field.
enum OnboardingMapper {

    static func map(_ answers: [QuizAnswer]) -> OnboardingAnswersDto? {
        var valuesByIndex: [Int: String] = [:]
        for answer in answers {
            valuesByIndex[answer.questionIndex] = answer.selectedOptionValue
        }

        guard
            let travelMotivation = valuesByIndex[1].flatMap(TravelMotivation.init(appValue:)),
            let planningStyle = valuesByIndex[2].flatMap(PlanningStyle.init(appValue:)),
            let budgetPriority = valuesByIndex[3].flatMap(BudgetPriority.init(appValue:)),
            let explorationApproach = valuesByIndex[4].flatMap(ExplorationApproach.init(appValue:)),
            let accommodationPreference = valuesByIndex[5].flatMap(AccommodationPreference.init(appValue:)),
            let travelPace = valuesByIndex[6].flatMap(TravelPace.init(appValue:)),
            let foodCulture = valuesByIndex[7].flatMap(FoodCulture.init(appValue:)),
            let transportPreference = valuesByIndex[8].flatMap(TransportPreference.init(appValue:)),
            let stressTolerance = valuesByIndex[9].flatMap(StressTolerance.init(appValue:)),
            let idealVacationSummary = valuesByIndex[10].flatMap(IdealVacationSummary.init(appValue:))
        else {
            return nil
        }

        return OnboardingAnswersDto(
            travelMotivation: travelMotivation,
            planningStyle: planningStyle,
            budgetPriority: budgetPriority,
            explorationApproach: explorationApproach,
            accommodationPreference: accommodationPreference,
            travelPace: travelPace,
            foodCulture: foodCulture,
            transportPreference: transportPreference,
            stressTolerance: stressTolerance,
            idealVacationSummary: idealVacationSummary
        )
    }
}

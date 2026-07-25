//
//  QuizAnswerStore.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Persists the user's most recent character-analysis quiz answers so the onboarding
/// flow can be re-entered later with the previous selections pre-filled.
final class QuizAnswerStore {

    static let shared = QuizAnswerStore()

    private enum Keys {
        static let answers = "com.voya.quizAnswers"
    }

    private init() {}

    var hasSavedAnswers: Bool {
        UserDefaults.standard.data(forKey: Keys.answers) != nil
    }

    func save(_ answers: [QuizAnswer]) {
        guard let data = try? JSONEncoder().encode(answers) else { return }
        UserDefaults.standard.set(data, forKey: Keys.answers)
    }

    func loadSelectedOptions() -> [QuizOption] {
        loadSavedAnswers()?.map { QuizOption(title: $0.selectedOptionTitle, value: $0.selectedOptionValue) } ?? []
    }

    func loadSavedAnswers() -> [QuizAnswer]? {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.answers),
            let answers = try? JSONDecoder().decode([QuizAnswer].self, from: data)
        else {
            return nil
        }
        return answers
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.answers)
    }
}

//
//  QuizAnswer.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct QuizAnswer: Codable {
    let questionIndex: Int
    let question: String
    let selectedOptionTitle: String
    let selectedOptionValue: String
}

struct CharacterAnalysisSubmission: Codable {
    let answers: [QuizAnswer]

    var jsonData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(self)
    }
}

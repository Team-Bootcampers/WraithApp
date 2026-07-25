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

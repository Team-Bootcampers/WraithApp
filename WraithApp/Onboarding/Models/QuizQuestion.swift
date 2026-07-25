//
//  QuizQuestion.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct QuizOption {
    let title: String
    let value: String
}

struct QuizQuestion {
    let iconName: String
    let title: String
    let options: [QuizOption]
    let insight: String
}

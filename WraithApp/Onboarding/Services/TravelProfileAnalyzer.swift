//
//  TravelProfileAnalyzer.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

// TODO: Replace with a real backend call that submits `answers` and returns the AI-generated result.
enum TravelProfileAnalyzer {

    private static let cultureValues: Set<String> = ["culture", "hidden_gem", "guided_tours", "culture_word", "activities", "diet_specific"]
    private static let adventureValues: Set<String> = ["adventure", "camping", "fast", "night_owl", "public_transport", "adaptable", "excitement"]
    private static let luxuryValues: Set<String> = ["luxury_stay", "resort", "boutique_hotel", "luxury", "private_transport", "relax", "peace"]

    static func analyze(answers: [QuizOption]) -> TravelIdentityResult {
        var cultureScore = 1
        var adventureScore = 1
        var luxuryScore = 1

        for answer in answers {
            if cultureValues.contains(answer.value) { cultureScore += 1 }
            if adventureValues.contains(answer.value) { adventureScore += 1 }
            if luxuryValues.contains(answer.value) { luxuryScore += 1 }
        }

        let scores: [(name: String, score: Int)] = [
            ("Kültür", cultureScore),
            ("Macera", adventureScore),
            ("Konfor", luxuryScore)
        ]
        let dominant = scores.max(by: { $0.score < $1.score }) ?? scores[0]

        switch dominant.name {
        case "Macera":
            return TravelIdentityResult(
                title: "Macera Ruhu",
                summary: "Profilinizi analiz ettik ve sizin için en uygun seyahat tarzını belirledik. Yapay zeka destekli asistanınız artık size özel öneriler sunmaya hazır.",
                insightTitle: "Seyahat Stiliniz",
                insightDescription: "Bilinmeyeni keşfetmekten güç alıyorsunuz. Sizin için seyahat, adrenalin ve doğayla baş başa kalmak demek. Rotanız zirveler, patikalar ve beklenmedik anlarla dolu olacak."
            )
        case "Konfor":
            return TravelIdentityResult(
                title: "Konfor Avcısı",
                summary: "Profilinizi analiz ettik ve sizin için en uygun seyahat tarzını belirledik. Yapay zeka destekli asistanınız artık size özel öneriler sunmaya hazır.",
                insightTitle: "Seyahat Stiliniz",
                insightDescription: "Seyahatin her anında konfor ve kaliteyi ön planda tutuyorsunuz. Sizin için tatil, dinlenmek ve kendinize değer katmak demek. Rotanız lüks konaklamalar ve özenli detaylarla şekillenecek."
            )
        default:
            return TravelIdentityResult(
                title: "Kültür Kaşifi",
                summary: "Profilinizi analiz ettik ve sizin için en uygun seyahat tarzını belirledik. Yapay zeka destekli asistanınız artık size özel öneriler sunmaya hazır.",
                insightTitle: "Seyahat Stiliniz",
                insightDescription: "Gittiğiniz şehrin ruhunu anlamayı seviyorsunuz. Sizin için seyahat sadece dinlenmek değil, öğrenmek ve deneyimlemek demek. Antik kalıntılardan çağdaş sanat galerilerine kadar her türlü kültürel zenginlik ilginizi çekiyor."
            )
        }
    }
}

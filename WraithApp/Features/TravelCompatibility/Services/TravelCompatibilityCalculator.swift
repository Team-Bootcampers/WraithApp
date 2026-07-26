//
//  TravelCompatibilityCalculator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Scores how well two travelers would travel together.
enum TravelCompatibilityCalculator {

    private static let sharedStrengthThreshold = 60
    private static let frictionThreshold = 40

    static func compare(mine: TravelPersona, theirs: TravelPersona) -> CompatibilityResult {
        let traitScores = TravelTrait.allCases.map { trait -> CompatibilityResult.TraitScore in
            let mineScore = mine.score(for: trait)
            let theirsScore = theirs.score(for: trait)
            return CompatibilityResult.TraitScore(
                trait: trait,
                score: 100 - abs(mineScore - theirsScore),
                mine: mineScore,
                theirs: theirsScore
            )
        }

        let blendedPersona = TravelPersona.blended(mine, theirs)
        let score = overallScore(from: traitScores)

        return CompatibilityResult(
            score: score,
            traitScores: traitScores.sorted { $0.score > $1.score },
            sharedStrengths: traitScores
                .filter { $0.mine >= sharedStrengthThreshold && $0.theirs >= sharedStrengthThreshold }
                .sorted { min($0.mine, $0.theirs) > min($1.mine, $1.theirs) }
                .map(\.trait),
            frictionPoints: traitScores
                .filter { abs($0.mine - $0.theirs) >= frictionThreshold }
                .sorted { $0.score < $1.score }
                .map(\.trait),
            verdictTitle: verdictTitle(for: score),
            verdictDescription: verdictDescription(for: score),
            blendedPersona: blendedPersona,
            suggestedDestination: DestinationCatalog.ranked(for: blendedPersona).first
        )
    }

    /// Traits either traveler feels strongly about weigh more, so agreeing on something
    /// neither of them cares about can't inflate the result.
    private static func overallScore(from traitScores: [CompatibilityResult.TraitScore]) -> Int {
        var weightedTotal = 0
        var weightTotal = 0

        for traitScore in traitScores {
            let weight = max(traitScore.mine, traitScore.theirs, 1)
            weightedTotal += traitScore.score * weight
            weightTotal += weight
        }

        guard weightTotal > 0 else { return 0 }
        return Int((Double(weightedTotal) / Double(weightTotal)).rounded())
    }

    private static func verdictTitle(for score: Int) -> String {
        switch score {
        case 85...: return "Seyahat Ruh İkizisiniz"
        case 70..<85: return "Harika Bir Ekipsiniz"
        case 55..<70: return "Uyumlu İkili"
        case 40..<55: return "Dengeli Zıtlıklar"
        default: return "Zıt Kutuplar"
        }
    }

    private static func verdictDescription(for score: Int) -> String {
        switch score {
        case 85...:
            return "Neredeyse aynı şeyleri istiyorsunuz. Aynı rotayı ikiniz de ayrı ayrı seçerdiniz — planlama aşamasında tartışma çıkmayacak."
        case 70..<85:
            return "Beklentileriniz büyük ölçüde örtüşüyor. Birkaç konuda farklı düşünseniz de bu, rotayı zenginleştiren türden bir fark."
        case 55..<70:
            return "Ortak zemininiz sağlam. Programda herkese birer gün ayırırsanız ikiniz de aradığınızı bulursunuz."
        case 40..<55:
            return "Farklı şeyler arıyorsunuz ama bu birbirinizi tamamlayabileceğiniz anlamına da geliyor. Günleri baştan paylaşmanız işi kolaylaştırır."
        default:
            return "Seyahat beklentileriniz oldukça farklı. Aynı rotada mutlu olmanız için programı net biçimde ikiye bölmeniz gerekir."
        }
    }
}

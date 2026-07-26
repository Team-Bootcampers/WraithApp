//
//  TravelPersona.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// A traveler's character-analysis result expressed as normalized (0...100) trait scores.
struct TravelPersona: Equatable {

    enum Archetype: String, CaseIterable {
        case cultureExplorer
        case adventureSeeker
        case comfortSeeker

        var title: String {
            switch self {
            case .cultureExplorer: return "Kültür Kaşifi"
            case .adventureSeeker: return "Macera Ruhu"
            case .comfortSeeker: return "Konfor Avcısı"
            }
        }

        var iconName: String {
            switch self {
            case .cultureExplorer: return "building.columns.fill"
            case .adventureSeeker: return "mountain.2.fill"
            case .comfortSeeker: return "sparkles"
            }
        }

        var trait: TravelTrait {
            switch self {
            case .cultureExplorer: return .culture
            case .adventureSeeker: return .adventure
            case .comfortSeeker: return .comfort
            }
        }

        var summary: String {
            switch self {
            case .cultureExplorer:
                return "Gittiğin şehrin hikâyesini öğrenmeden dönmüyorsun. Rotaların müzeler, tarihi dokular ve yerel yaşamla şekilleniyor."
            case .adventureSeeker:
                return "Planın bir kısmı hep boş kalsın istiyorsun. Doğa, hareket ve beklenmedik keşifler senin için seyahatin ta kendisi."
            case .comfortSeeker:
                return "Seyahatin dinlendirmesi gerektiğine inanıyorsun. Konfor, kalite ve zahmetsiz bir program senin önceliğin."
            }
        }
    }

    let traits: [TravelTrait: Int]

    /// The trait the traveler scores highest on among the three headline axes.
    var archetype: Archetype {
        Archetype.allCases.max { score(for: $0.trait) < score(for: $1.trait) } ?? .cultureExplorer
    }

    /// Traits sorted strongest-first — used wherever a persona is summarized in the UI.
    var rankedTraits: [(trait: TravelTrait, score: Int)] {
        TravelTrait.allCases
            .map { (trait: $0, score: score(for: $0)) }
            .sorted { $0.score > $1.score }
    }

    func score(for trait: TravelTrait) -> Int {
        traits[trait] ?? 0
    }

    /// Midpoint of two personas, used to plan a trip that suits a pair of travelers.
    static func blended(_ first: TravelPersona, _ second: TravelPersona) -> TravelPersona {
        var traits: [TravelTrait: Int] = [:]
        for trait in TravelTrait.allCases {
            traits[trait] = (first.score(for: trait) + second.score(for: trait)) / 2
        }
        return TravelPersona(traits: traits)
    }
}

// MARK: - Codable

/// Encoded as a plain score array in `TravelTrait.allCases` order so persisted personas
/// and shared compatibility codes stay compact and stable.
extension TravelPersona: Codable {

    private enum CodingKeys: String, CodingKey {
        case scores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scores = try container.decode([Int].self, forKey: .scores)

        var traits: [TravelTrait: Int] = [:]
        for (index, trait) in TravelTrait.allCases.enumerated() where index < scores.count {
            traits[trait] = scores[index]
        }
        self.init(traits: traits)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(TravelTrait.allCases.map { score(for: $0) }, forKey: .scores)
    }
}

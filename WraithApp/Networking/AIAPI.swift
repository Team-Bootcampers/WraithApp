//
//  AIAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

private struct TravelPersonalityRequestDto: Encodable {
    let answers: OnboardingAnswersDto
}

struct TravelPersonalityResponseDto: Decodable {
    let analysis: String
}

/// Wraps `/ai/travel-personality` from the CoreBackendKit API — takes the same onboarding
/// answers already sent to `/users/{id}/onboarding` and returns a Gemini-generated
/// character-analysis write-up.
enum AIAPI {

    static func travelPersonality(answers: OnboardingAnswersDto, token: String) async throws -> TravelPersonalityResponseDto {
        try await APIClient.shared.request(
            path: "/ai/travel-personality",
            method: "POST",
            body: TravelPersonalityRequestDto(answers: answers),
            authToken: token
        )
    }
}

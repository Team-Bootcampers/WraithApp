//
//  PersonaShareCode.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Packs a persona into a short, shareable text code.
///
/// Compatibility matching needs a second traveler's persona, but nothing about it is private
/// or server-owned — so instead of a backend round-trip, travelers just swap a code. This
/// keeps the feature usable offline and between people who aren't connected in the app.
enum PersonaShareCode {

    private static let prefix = "VOYA-"

    static func encode(_ persona: TravelPersona) -> String {
        guard let data = try? JSONEncoder().encode(persona) else { return "" }
        return prefix + base64URLEncoded(data)
    }

    static func decode(_ code: String) -> TravelPersona? {
        let trimmed = code
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: prefix, with: "", options: .caseInsensitive)

        guard
            !trimmed.isEmpty,
            let data = base64URLDecoded(trimmed),
            let persona = try? JSONDecoder().decode(TravelPersona.self, from: data)
        else {
            return nil
        }
        return persona
    }

    // MARK: - Base64 URL

    private static func base64URLEncoded(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func base64URLDecoded(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        return Data(base64Encoded: base64)
    }
}

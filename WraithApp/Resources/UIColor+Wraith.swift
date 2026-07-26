//
//  UIColor+Wraith.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

extension UIColor {

    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    /// A color that resolves to a different hex value in light vs. dark appearance.
    convenience init(light: String, dark: String) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }

    // MARK: - Wraith Design Tokens (Voya - Onboarding)
    // Yellow / red palette, dark-mode aware.

    static let wraithPrimary = UIColor(light: "#E63946", dark: "#FF5A67")
    static let wraithSecondary = UIColor(light: "#FFC145", dark: "#FFCF6B")
    static let wraithBackground = UIColor(light: "#FFFFFF", dark: "#17130F")
    static let wraithOnSurface = UIColor(light: "#2B2118", dark: "#F5EDE4")
    static let wraithOnSurfaceVariant = UIColor(light: "#7A6F63", dark: "#B8AA9C")
    static let wraithOutlineVariant = UIColor(light: "#F0E4C8", dark: "#3A322A")
    static let wraithSurfaceContainerLowest = UIColor(light: "#FFFFFF", dark: "#0F0C09")
    static let wraithOutline = UIColor(light: "#A69C8E", dark: "#6B5F53")
    static let wraithSurface = UIColor(light: "#FFFFFF", dark: "#241E18")
    static let wraithSurfaceVariant = UIColor(light: "#FFF3D6", dark: "#3D3120")
    static let wraithOnPrimary = UIColor.white

    static let wraithPrimaryDeep = UIColor(light: "#C6303C", dark: "#E64550")
    static let wraithOnSecondary = UIColor(light: "#2B2118", dark: "#2B2118")
    /// Destructive/error state (delete actions, validation messages) — deliberately distinct
    /// from `wraithPrimary` even though both are red-toned, so a destructive affordance never
    /// reads as "selected/active" (which already uses `wraithPrimary`).
    static let wraithError = UIColor(light: "#DC2626", dark: "#F87171")

    // MARK: - Photo Scrims

    /// Fixed-black overlays for legibility on top of arbitrary photo content (cards, hero
    /// images). Intentionally NOT theme-aware like the tokens above — a photo needs the same
    /// darkening treatment regardless of the app's light/dark mode.
    static let wraithPhotoScrimLight = UIColor.black.withAlphaComponent(0.28)
    static let wraithPhotoScrimHeavy = UIColor.black.withAlphaComponent(0.78)

    /// Card drop-shadow color — same reasoning as the scrims above, a shadow needs to stay a
    /// fixed dark tone regardless of theme rather than following `wraithOnSurface`.
    static let wraithCardShadow = UIColor.black.withAlphaComponent(0.08)
}

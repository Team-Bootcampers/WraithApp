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
    /// Grouped-list style background: clearly darker than `wraithSurface` so cards read as
    /// elevated content sitting on the screen instead of blending into a flat white page.
    static let wraithBackground = UIColor(light: "#EEECE5", dark: "#17130F")
    static let wraithOnSurface = UIColor(light: "#2B2118", dark: "#F5EDE4")
    static let wraithOnSurfaceVariant = UIColor(light: "#7A6F63", dark: "#B8AA9C")
    static let wraithOutlineVariant = UIColor(light: "#E7E2DA", dark: "#4A4038")
    static let wraithSurfaceContainerLowest = UIColor(light: "#FFFFFF", dark: "#0F0C09")
    static let wraithOutline = UIColor(light: "#A69C8E", dark: "#6B5F53")
    static let wraithSurface = UIColor(light: "#FFFFFF", dark: "#241E18")
    /// Neutral warm-gray fill for placeholders/unselected chips — kept off the brand yellow
    /// so it reads as a true "inactive" state rather than a highlighted one.
    static let wraithSurfaceVariant = UIColor(light: "#F0EDE7", dark: "#2E2A24")
    static let wraithOnPrimary = UIColor.white

    static let wraithPrimaryDeep = UIColor(light: "#C6303C", dark: "#E64550")
    static let wraithOnSecondary = UIColor(light: "#2B2118", dark: "#2B2118")
    /// Destructive/error state (delete actions, validation messages) — deliberately distinct
    /// from `wraithPrimary` even though both are red-toned, so a destructive affordance never
    /// reads as "selected/active" (which already uses `wraithPrimary`).
    static let wraithError = UIColor(light: "#DC2626", dark: "#F87171")

    /// "This item is picked" affordance (selectable POI cards, checkmarks) — Apple's own
    /// system blue rather than the red brand accent, so a selection never reads as
    /// destructive/error and stays instantly recognizable the way iOS's own selection UI is.
    static let wraithSelection = UIColor.systemBlue

    // MARK: - Photo Scrims

    /// Fixed-black overlays for legibility on top of arbitrary photo content (cards, hero
    /// images). Intentionally NOT theme-aware like the tokens above — a photo needs the same
    /// darkening treatment regardless of the app's light/dark mode.
    static let wraithPhotoScrimLight = UIColor.black.withAlphaComponent(0.28)
    static let wraithPhotoScrimHeavy = UIColor.black.withAlphaComponent(0.78)

    /// Card drop-shadow color — same reasoning as the scrims above, a shadow needs to stay a
    /// fixed dark tone regardless of theme rather than following `wraithOnSurface`.
    static let wraithCardShadow = UIColor.black.withAlphaComponent(0.14)
}

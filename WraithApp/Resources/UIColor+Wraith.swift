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

    // MARK: - Wraith Design Tokens (Voyage Insight AI - Onboarding)
    // Yellow / red / white palette.

    static let wraithPrimary = UIColor(hex: "#E63946")
    static let wraithSecondary = UIColor(hex: "#FFC145")
    static let wraithBackground = UIColor(hex: "#FFFFFF")
    static let wraithOnSurface = UIColor(hex: "#2B2118")
    static let wraithOnSurfaceVariant = UIColor(hex: "#7A6F63")
    static let wraithOutlineVariant = UIColor(hex: "#F0E4C8")
    static let wraithSurfaceContainerLowest = UIColor(hex: "#FFFFFF")
    static let wraithOutline = UIColor(hex: "#A69C8E")
    static let wraithSurface = UIColor(hex: "#FFFFFF")
    static let wraithSurfaceVariant = UIColor(hex: "#FFF3D6")
}

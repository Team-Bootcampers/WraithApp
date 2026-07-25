//
//  TripAccentTheme.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

enum TripAccentTheme {
    static let accent = UIColor(red: 0.95, green: 0.47, blue: 0.31, alpha: 1)
    static let accentDeep = UIColor(red: 0.88, green: 0.34, blue: 0.28, alpha: 1)

    static var gradientColors: [CGColor] {
        [accent.cgColor, accentDeep.cgColor]
    }

    static var accentSoftBackground: UIColor {
        accent.withAlphaComponent(0.12)
    }

    static var accentBorder: UIColor {
        accent.withAlphaComponent(0.5)
    }

    static var cardShadowColor: UIColor {
        UIColor.black.withAlphaComponent(0.08)
    }
}

extension UIView {
    func applyCardShadow() {
        layer.shadowColor = TripAccentTheme.cardShadowColor.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }
}

//
//  TripAccentTheme.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

enum TripAccentTheme {
    static let accent = UIColor.wraithPrimary
    static let accentDeep = UIColor.wraithPrimaryDeep

    static var gradientColors: [CGColor] {
        [accent.cgColor, accentDeep.cgColor]
    }

    static var accentSoftBackground: UIColor {
        accent.withAlphaComponent(0.12)
    }

    static var cardShadowColor: UIColor {
        .wraithCardShadow
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

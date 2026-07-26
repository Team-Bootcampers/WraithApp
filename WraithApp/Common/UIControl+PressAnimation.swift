//
//  UIControl+PressAnimation.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

extension UIControl {
    /// Wires up a standard iOS-style press feedback (slight scale-down + dim on touch-down,
    /// spring back on release) so tappable controls that don't already implement their own
    /// `isHighlighted` visuals feel responsive instead of static.
    func applyStandardPressAnimation() {
        addTarget(self, action: #selector(wraithPressBegan), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(wraithPressEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func wraithPressBegan() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.85
        }
    }

    @objc private func wraithPressEnded() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}

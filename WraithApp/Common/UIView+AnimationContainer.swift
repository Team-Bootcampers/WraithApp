//
//  UIView+AnimationContainer.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

extension UIView {
    /// The nearest scrolling ancestor (or self, if none is found). Animating a layout
    /// change by calling `layoutIfNeeded()` on this — rather than on `window` — keeps the
    /// animation scoped to the scrollable content instead of forcing a layout pass of the
    /// entire app (status bar, nav bar, etc.), which is what was causing the stutter.
    var nearestScrollViewOrSelf: UIView {
        var view: UIView? = self
        while let current = view {
            if current is UIScrollView {
                return current
            }
            view = current.superview
        }
        return self
    }
}

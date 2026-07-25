//
//  GradientView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class GradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    init() {
        super.init(frame: .zero)
        gradientLayer.colors = TripAccentTheme.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

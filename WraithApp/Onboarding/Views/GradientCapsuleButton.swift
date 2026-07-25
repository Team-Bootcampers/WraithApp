//
//  GradientCapsuleButton.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class GradientCapsuleButton: UIButton {

    private let gradientLayer = CAGradientLayer()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String) {
        gradientLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.white, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        contentEdgeInsets = UIEdgeInsets(top: 18, left: 32, bottom: 18, right: 32)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
    }
}

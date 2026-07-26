//
//  GradientCapsuleButton.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class GradientCapsuleButton: UIButton {

    private let gradientLayer = CAGradientLayer()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .wraithOnPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private var titleBeforeLoading: String?

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        if isLoading {
            titleBeforeLoading = title(for: .normal)
            setTitle(nil, for: .normal)
            activityIndicator.startAnimating()
        } else {
            setTitle(titleBeforeLoading, for: .normal)
            activityIndicator.stopAnimating()
        }
    }

    private func setup(title: String) {
        gradientLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true

        setTitle(title, for: .normal)
        setTitleColor(.wraithOnPrimary, for: .normal)
        setTitleColor(.wraithOnPrimary, for: .highlighted)
        setTitleColor(.wraithOnPrimary, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        contentEdgeInsets = UIEdgeInsets(
            top: WraithSpacing.space18,
            left: WraithSpacing.space32,
            bottom: WraithSpacing.space18,
            right: WraithSpacing.space32
        )

        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        applyStandardPressAnimation()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        gradientLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
    }
}

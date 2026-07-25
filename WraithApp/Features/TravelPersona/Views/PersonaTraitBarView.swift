//
//  PersonaTraitBarView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// A single labelled 0...100 trait bar, matching the onboarding progress-bar treatment.
final class PersonaTraitBarView: UIView {

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var fillView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithPrimary
        view.layer.cornerRadius = WraithRadius.radius3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private var fillWidthConstraint: NSLayoutConstraint?

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        [iconImageView, titleLabel, valueLabel, trackView].forEach { addSubview($0) }
        trackView.addSubview(fillView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: WraithSpacing.space8),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: WraithSpacing.space8),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),

            trackView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: WraithSpacing.space8),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            trackView.heightAnchor.constraint(equalToConstant: 6),

            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
    }

    // MARK: - Public

    func configure(iconSystemName: String, title: String, valueText: String, ratio: Double, tintColor: UIColor = .wraithPrimary) {
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = tintColor
        fillView.backgroundColor = tintColor
        titleLabel.text = title
        valueLabel.text = valueText

        fillWidthConstraint?.isActive = false
        let clamped = min(max(ratio, 0), 1)
        // A zero multiplier is rejected by Auto Layout, so an empty bar is expressed as a
        // zero-constant width instead.
        fillWidthConstraint = clamped == 0
            ? fillView.widthAnchor.constraint(equalToConstant: 0)
            : fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: clamped)
        fillWidthConstraint?.isActive = true
    }
}

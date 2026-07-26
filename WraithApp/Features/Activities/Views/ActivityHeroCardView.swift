//
//  ActivityHeroCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// A full-width gradient hero card for a persona-driven feature entry point on the
/// "Etkinlikler" tab — bigger and punchier than a plain list row, since these are the tab's
/// only content.
final class ActivityHeroCardView: UIControl {

    // MARK: - UI Components

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.layer.cornerRadius = WraithRadius.radius24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .wraithOnPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var chevronContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.layer.cornerRadius = WraithRadius.radius16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up.right"))
        imageView.tintColor = .wraithOnPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.textColor = .wraithOnPrimary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.wraithOnPrimary.withAlphaComponent(0.85)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var topRowStackView: UIStackView = {
        let spacer = UIView()
        let stack = UIStackView(arrangedSubviews: [iconContainerView, spacer, chevronContainerView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topRowStackView, textStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(iconSystemName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setupAppearance()
        setupLayout()
        applyStandardPressAnimation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        // The app's largest radius token — these hero cards span the full screen width, so
        // even radius28 reads as barely-rounded at that scale; radius38 is what actually
        // reads as "soft" on a card this big.
        layer.cornerRadius = WraithRadius.radius38
        layer.insertSublayer(gradientLayer, at: 0)
        applyCardShadow()
    }

    private func setupLayout() {
        iconContainerView.addSubview(iconImageView)
        chevronContainerView.addSubview(chevronImageView)
        addSubview(contentStackView)

        // Purely decorative — without this, tapping directly on the icon/chevron/text (i.e.
        // most of the card) hit-tests to that subview instead of `self`, so only the empty
        // padding around them actually triggered `touchUpInside`. Disabling interaction on
        // the whole subtree makes every point in the card fall through to this control.
        contentStackView.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            chevronContainerView.widthAnchor.constraint(equalToConstant: 32),
            chevronContainerView.heightAnchor.constraint(equalToConstant: 32),
            chevronImageView.centerXAnchor.constraint(equalTo: chevronContainerView.centerXAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: chevronContainerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 15),
            chevronImageView.heightAnchor.constraint(equalToConstant: 15),

            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space20),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space20),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WraithSpacing.space20)
        ])
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

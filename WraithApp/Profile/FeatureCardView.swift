//
//  FeatureCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Entry-point card for one of Profile's persona-driven features.
final class FeatureCardView: UIControl {

    // MARK: - UI Components

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .wraithOnSurfaceVariant
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius16
        layer.borderWidth = WraithBorderWidth.hairline
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    private func setupLayout() {
        iconContainerView.addSubview(iconImageView)
        [iconContainerView, textStackView, chevronImageView].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            iconContainerView.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space16),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            iconContainerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -WraithSpacing.space16),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            textStackView.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: WraithSpacing.space12),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -WraithSpacing.space12),
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space16),
            textStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WraithSpacing.space16),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16),
            chevronImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1.0 }
    }
}

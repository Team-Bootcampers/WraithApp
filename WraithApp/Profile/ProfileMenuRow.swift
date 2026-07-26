//
//  ProfileMenuRow.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Tappable card row used for navigation entries on the Profile screen (e.g. legal documents).
final class ProfileMenuRow: UIControl {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .wraithOnSurface
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithOnSurfaceVariant
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius12
        layer.borderWidth = WraithBorderWidth.hairline
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor

        addSubview(titleLabel)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -WraithSpacing.space8)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1.0 }
    }
}

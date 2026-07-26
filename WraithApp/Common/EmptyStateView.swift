//
//  EmptyStateView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// A centered icon + title + subtitle block for "nothing to show here" screens — shared so
/// every empty state (Seyahatlerim, Anasayfa, ...) looks and behaves the same. Starts hidden;
/// callers toggle `isHidden` themselves based on their own loading/content state.
final class EmptyStateView: UIView {

    // MARK: - UI Components

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius38
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
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = WraithSpacing.space8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconContainerView, textStackView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = WraithSpacing.space20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(iconSystemName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        iconImageView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        iconContainerView.addSubview(iconImageView)
        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: 76),
            iconContainerView.heightAnchor.constraint(equalToConstant: 76),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 34),
            iconImageView.heightAnchor.constraint(equalToConstant: 34),

            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

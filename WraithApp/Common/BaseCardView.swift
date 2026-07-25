//
//  BaseCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

class BaseCardView: UIView {

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurface
        view.layer.cornerRadius = WraithRadius.radius18
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = TripAccentTheme.accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var iconBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = TripAccentTheme.accentSoftBackground
        view.layer.cornerRadius = WraithRadius.radius16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerStackView, contentContainerView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(title: String, iconSystemName: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconBadgeView.addSubview(iconImageView)
        headerStackView.addArrangedSubview(iconBadgeView)
        setupAppearance()
        setupLayout()
        NSLayoutConstraint.activate([
            iconBadgeView.widthAnchor.constraint(equalToConstant: 32),
            iconBadgeView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.centerXAnchor.constraint(equalTo: iconBadgeView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBadgeView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 15),
            iconImageView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }

    init(title: String, accessoryView: UIView) {
        super.init(frame: .zero)
        titleLabel.text = title
        headerStackView.addArrangedSubview(accessoryView)
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .clear
        applyCardShadow()
    }

    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: WraithSpacing.space16),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: WraithSpacing.space16),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -WraithSpacing.space16),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -WraithSpacing.space16)
        ])
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        // An explicit shadow path lets Core Animation skip re-rasterizing the shadow's
        // alpha mask on every frame — without it, animating this view (e.g. collapsing a
        // StopSectionView) is noticeably janky since the shadow shape is recomputed live.
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    // MARK: - Public

    /// Lets a container-like subclass (e.g. a collapsible stop section) visually recede
    /// behind the cards nested inside it, instead of both sitting on the same background tier.
    func configureContainer(backgroundColor: UIColor, borderColor: UIColor? = nil) {
        containerView.backgroundColor = backgroundColor
        containerView.layer.borderWidth = borderColor == nil ? 0 : 1
        containerView.layer.borderColor = borderColor?.cgColor
    }

    /// Lets a subclass update its header title after construction (e.g. renumbering a stop
    /// section after another stop ahead of it was deleted).
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
}

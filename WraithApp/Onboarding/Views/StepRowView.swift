//
//  StepRowView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class StepRowView: UIView {

    private let numberBadgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius18
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .wraithPrimary
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    init(number: Int, title: String, description: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "\(number)"
        titleLabel.text = title
        descriptionLabel.text = description
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        numberBadgeView.addSubview(numberLabel)
        addSubview(numberBadgeView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            numberBadgeView.widthAnchor.constraint(equalToConstant: 36),
            numberBadgeView.heightAnchor.constraint(equalToConstant: 36),
            numberBadgeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberBadgeView.topAnchor.constraint(equalTo: topAnchor),

            numberLabel.centerXAnchor.constraint(equalTo: numberBadgeView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: numberBadgeView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space4),
            titleLabel.leadingAnchor.constraint(equalTo: numberBadgeView.trailingAnchor, constant: WraithSpacing.space16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: WraithSpacing.space4),
            descriptionLabel.leadingAnchor.constraint(equalTo: numberBadgeView.trailingAnchor, constant: WraithSpacing.space16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

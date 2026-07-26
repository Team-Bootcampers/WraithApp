//
//  MysteryDestinationCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// The sealed-envelope state of a surprise trip: shows every clue except the destination.
final class MysteryDestinationCardView: BaseCardView {

    // MARK: - UI Components

    private lazy var maskedNameLabel: UILabel = {
        let label = UILabel()
        label.text = "? ? ?"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .wraithPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Rotan hazır — açmaya var mısın?"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var hintsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [maskedNameLabel, captionLabel, hintsStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space20
        stack.setCustomSpacing(WraithSpacing.space8, after: maskedNameLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init() {
        super.init(title: "Sürpriz Destinasyon", iconSystemName: "gift.fill")
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }

    // MARK: - Binding

    func configure(with plan: ItineraryPlan, nights: Int) {
        guard let destination = plan.primaryDestination else { return }

        hintsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let hints: [(icon: String, text: String)] = [
            ("thermometer.medium", destination.climateHint),
            ("airplane.departure", destination.travelHint),
            ("moon.stars.fill", "\(nights) gecelik program"),
            ("sparkles", "Profiline %\(plan.matchScore) uyumlu"),
            ("turkishlirasign.circle.fill", "Tahmini toplam \(plan.totalCost) TL")
        ]

        hints.forEach { hintsStackView.addArrangedSubview(makeHintRow(iconSystemName: $0.icon, text: $0.text)) }
    }

    private func makeHintRow(iconSystemName: String, text: String) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: iconSystemName))
        iconImageView.tintColor = .wraithPrimary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        return stack
    }
}

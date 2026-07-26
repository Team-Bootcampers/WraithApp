//
//  ItineraryPlanCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Preview of a generated `ItineraryPlan`: destination, match score, reasoning and cost.
final class ItineraryPlanCardView: BaseCardView {

    // MARK: - UI Components

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = WraithRadius.radius3
        imageView.backgroundColor = .wraithSurfaceVariant
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var destinationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var matchBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .wraithOnPrimary
        label.textAlignment = .center
        label.backgroundColor = .wraithPrimary
        label.layer.cornerRadius = WraithRadius.radius11
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var highlightsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var costLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .wraithPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var costCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tahmini toplam maliyet"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var costStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [costCaptionLabel, costLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [flagImageView, destinationLabel, matchBadgeLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerStackView, taglineLabel, highlightsStackView, costStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.setCustomSpacing(WraithSpacing.space8, after: headerStackView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init() {
        super.init(title: "Önerilen Rota", iconSystemName: "map.fill")
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
            contentStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            flagImageView.widthAnchor.constraint(equalToConstant: 30),
            flagImageView.heightAnchor.constraint(equalToConstant: 21),

            matchBadgeLabel.widthAnchor.constraint(equalToConstant: 88),
            matchBadgeLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    // MARK: - Binding

    func configure(with plan: ItineraryPlan) {
        guard let destination = plan.primaryDestination else { return }

        updateTitle(plan.destinations.count > 1 ? "Önerilen Çoklu Rota" : "Önerilen Rota")
        flagImageView.setImage(from: destination.country.flagURL)
        destinationLabel.text = plan.destinations.map(\.cityName).joined(separator: " → ")
        matchBadgeLabel.text = "%\(plan.matchScore) uyum"
        taglineLabel.text = destination.tagline
        costLabel.text = "\(plan.totalCost) TL"

        highlightsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        plan.highlights.forEach { highlightsStackView.addArrangedSubview(makeHighlightRow(text: $0)) }
    }

    private func makeHighlightRow(text: String) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
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
        stack.alignment = .top
        stack.spacing = WraithSpacing.space10
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        return stack
    }
}

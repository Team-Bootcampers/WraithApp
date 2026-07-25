//
//  CompatibilityResultCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Compatibility verdict: headline score, what the pair agrees on, and where they diverge.
final class CompatibilityResultCardView: BaseCardView {

    // MARK: - UI Components

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 44, weight: .bold)
        label.textColor = .wraithPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var verdictTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var verdictDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var traitsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var sharedStrengthsLabel = makeFootnoteLabel()

    private lazy var frictionLabel = makeFootnoteLabel()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            scoreLabel,
            verdictTitleLabel,
            verdictDescriptionLabel,
            traitsStackView,
            sharedStrengthsLabel,
            frictionLabel
        ])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.setCustomSpacing(WraithSpacing.space4, after: scoreLabel)
        stack.setCustomSpacing(WraithSpacing.space8, after: verdictTitleLabel)
        stack.setCustomSpacing(WraithSpacing.space8, after: sharedStrengthsLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init() {
        super.init(title: "Uyum Sonucu", iconSystemName: "heart.text.square.fill")
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

    private func makeFootnoteLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Binding

    func configure(with result: CompatibilityResult) {
        scoreLabel.text = "%\(result.score)"
        verdictTitleLabel.text = result.verdictTitle
        verdictDescriptionLabel.text = result.verdictDescription

        traitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for traitScore in result.traitScores {
            let barView = PersonaTraitBarView()
            barView.configure(
                iconSystemName: traitScore.trait.iconName,
                title: traitScore.trait.title,
                valueText: "%\(traitScore.score)",
                ratio: Double(traitScore.score) / 100,
                tintColor: traitScore.score >= 60 ? .wraithPrimary : .wraithSecondary
            )
            traitsStackView.addArrangedSubview(barView)
        }

        sharedStrengthsLabel.isHidden = result.sharedStrengths.isEmpty
        sharedStrengthsLabel.text = "Ortak güçlü yanlarınız: " + result.sharedStrengths.map(\.title).joined(separator: ", ")

        frictionLabel.isHidden = result.frictionPoints.isEmpty
        frictionLabel.text = "Dikkat etmeniz gereken konular: " + result.frictionPoints.map(\.title).joined(separator: ", ")
    }
}

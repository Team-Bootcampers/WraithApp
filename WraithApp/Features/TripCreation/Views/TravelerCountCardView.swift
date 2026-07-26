//
//  TravelerCountCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class TravelerCountCardView: BaseCardView, TripCreationCardUpdating {

    // MARK: - UI Components

    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = TripAccentTheme.accent
        button.backgroundColor = .wraithSurfaceVariant
        button.layer.cornerRadius = WraithRadius.radius16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        return button
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = TripAccentTheme.accent
        button.backgroundColor = .wraithSurfaceVariant
        button.layer.cornerRadius = WraithRadius.radius16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        return button
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var counterStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minusButton, countLabel, plusButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private let viewModel: TripCreationViewModel

    // MARK: - Init

    init(viewModel: TripCreationViewModel) {
        self.viewModel = viewModel
        super.init(title: "Kaç kişi seyahat edecek?", iconSystemName: "person.2")
        setupLayout()
        update(with: viewModel.draft)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(counterStackView)
        NSLayoutConstraint.activate([
            counterStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            counterStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            counterStackView.centerXAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
            counterStackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainerView.leadingAnchor),
            counterStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 32),
            minusButton.heightAnchor.constraint(equalToConstant: 32),
            plusButton.widthAnchor.constraint(equalToConstant: 32),
            plusButton.heightAnchor.constraint(equalToConstant: 32),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    // MARK: - Binding

    func update(with draft: TripCreationDraft) {
        countLabel.text = "\(draft.travelerCount)"
        minusButton.isEnabled = draft.travelerCount > 1
        minusButton.alpha = minusButton.isEnabled ? 1 : 0.3
    }

    // MARK: - Actions

    @objc private func didTapMinusButton() {
        viewModel.decrementTravelerCount()
    }

    @objc private func didTapPlusButton() {
        viewModel.incrementTravelerCount()
    }
}

//
//  TripBasicsCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Start date + traveler count input, shared by the auto-planning features.
final class TripBasicsCardView: BaseCardView {

    // MARK: - UI Components

    private lazy var dateTitleLabel = makeRowTitleLabel(text: "Başlangıç tarihi")

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Date()
        picker.tintColor = .wraithPrimary
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var travelerTitleLabel = makeRowTitleLabel(text: "Kişi sayısı")

    private lazy var minusButton = makeStepperButton(systemName: "minus", action: #selector(didTapMinus))

    private lazy var plusButton = makeStepperButton(systemName: "plus", action: #selector(didTapPlus))

    private lazy var travelerCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var travelerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minusButton, travelerCountLabel, plusButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private(set) var travelerCount = 2 {
        didSet {
            travelerCountLabel.text = "\(travelerCount)"
            minusButton.isEnabled = travelerCount > 1
            minusButton.alpha = minusButton.isEnabled ? 1 : 0.3
        }
    }

    var startDate: Date { datePicker.date }

    // MARK: - Init

    init() {
        super.init(title: "Seyahat Bilgileri", iconSystemName: "slider.horizontal.3")
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        travelerCount = 2
        datePicker.date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        [dateTitleLabel, datePicker, travelerTitleLabel, travelerStackView].forEach { contentContainerView.addSubview($0) }

        NSLayoutConstraint.activate([
            dateTitleLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            dateTitleLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            dateTitleLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),

            datePicker.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: dateTitleLabel.trailingAnchor, constant: WraithSpacing.space12),

            travelerTitleLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: WraithSpacing.space20),
            travelerTitleLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            travelerTitleLabel.centerYAnchor.constraint(equalTo: travelerStackView.centerYAnchor),

            travelerStackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: WraithSpacing.space16),
            travelerStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            travelerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: travelerTitleLabel.trailingAnchor, constant: WraithSpacing.space12),
            travelerStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            minusButton.widthAnchor.constraint(equalToConstant: 32),
            minusButton.heightAnchor.constraint(equalToConstant: 32),
            plusButton.widthAnchor.constraint(equalToConstant: 32),
            plusButton.heightAnchor.constraint(equalToConstant: 32),
            travelerCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    private func makeRowTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeStepperButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .wraithPrimary
        button.backgroundColor = .wraithSurfaceVariant
        button.layer.cornerRadius = WraithRadius.radius16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func didTapMinus() {
        guard travelerCount > 1 else { return }
        travelerCount -= 1
    }

    @objc private func didTapPlus() {
        travelerCount += 1
    }
}

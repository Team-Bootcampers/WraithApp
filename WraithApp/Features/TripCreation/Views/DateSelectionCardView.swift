//
//  DateSelectionCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class DateSelectionCardView: BaseCardView, TripCreationCardUpdating {

    private enum DateTarget {
        case start
        case end
    }

    // MARK: - UI Components

    private lazy var departureBox: DateBoxView = {
        let box = DateBoxView(caption: "GİDİŞ")
        box.translatesAutoresizingMaskIntoConstraints = false
        box.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDepartureBox)))
        return box
    }()

    private lazy var returnBox: DateBoxView = {
        let box = DateBoxView(caption: "DÖNÜŞ")
        box.translatesAutoresizingMaskIntoConstraints = false
        box.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapReturnBox)))
        return box
    }()

    private lazy var boxesStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [departureBox, returnBox])
        stack.axis = .horizontal
        stack.spacing = WraithSpacing.space12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = Date()
        picker.isHidden = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return picker
    }()

    private lazy var confirmButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Tamam"
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = WraithRadius.radius12
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [boxesStackView, datePicker, confirmButton])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    // MARK: - Properties

    private let viewModel: TripCreationViewModel
    private var activeTarget: DateTarget?

    // MARK: - Init

    init(viewModel: TripCreationViewModel) {
        self.viewModel = viewModel
        super.init(title: "Tarih Seçimi", iconSystemName: "calendar")
        setupLayout()
        update(with: viewModel.draft)
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
            departureBox.heightAnchor.constraint(equalToConstant: WraithSpacing.space60),
            returnBox.heightAnchor.constraint(equalToConstant: WraithSpacing.space60)
        ])
    }

    // MARK: - Binding

    func update(with draft: TripCreationDraft) {
        departureBox.setDateText(text(for: draft.startDate))
        returnBox.setDateText(text(for: draft.endDate))
    }

    private func text(for date: Date?) -> String {
        guard let date else { return "Seçiniz" }
        return dateFormatter.string(from: date)
    }

    // MARK: - Actions

    @objc private func didTapDepartureBox() {
        // Tapping the box that's already open closes it — otherwise there was no way to
        // dismiss the picker after reopening it without actually changing the date, since
        // `.valueChanged` only fires when the value truly changes.
        guard !(!datePicker.isHidden && activeTarget == .start) else {
            closePicker()
            return
        }
        activeTarget = .start
        datePicker.minimumDate = Date()
        datePicker.date = viewModel.startDate ?? Date()
        showPicker()
        departureBox.setActive(true)
        returnBox.setActive(false)
    }

    @objc private func didTapReturnBox() {
        guard !(!datePicker.isHidden && activeTarget == .end) else {
            closePicker()
            return
        }
        activeTarget = .end
        let minimumDate = viewModel.minimumReturnDate
        datePicker.minimumDate = minimumDate
        datePicker.date = viewModel.endDate ?? minimumDate
        showPicker()
        departureBox.setActive(false)
        returnBox.setActive(true)
    }

    @objc private func didChangeDate() {
        applySelectedDate()
        closePicker()
    }

    @objc private func didTapConfirm() {
        // Tapping the already-selected date inside the inline calendar doesn't fire
        // `.valueChanged` (the value never actually changes), which used to leave the
        // picker stuck open with no way to confirm/dismiss it. This button always applies
        // whatever date the picker is currently showing and closes, regardless of whether
        // the value changed.
        applySelectedDate()
        closePicker()
    }

    private func applySelectedDate() {
        switch activeTarget {
        case .start:
            viewModel.selectStartDate(datePicker.date)
        case .end:
            viewModel.selectEndDate(datePicker.date)
        case .none:
            break
        }
    }

    private func closePicker() {
        hidePicker()
        departureBox.setActive(false)
        returnBox.setActive(false)
        activeTarget = nil
    }

    // MARK: - Picker Presentation

    private func showPicker() {
        guard datePicker.isHidden else { return }
        let animationContainer = nearestScrollViewOrSelf
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.datePicker.isHidden = false
            self.confirmButton.isHidden = false
            animationContainer.layoutIfNeeded()
        }
    }

    private func hidePicker() {
        guard !datePicker.isHidden else { return }
        let animationContainer = nearestScrollViewOrSelf
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.datePicker.isHidden = true
            self.confirmButton.isHidden = true
            animationContainer.layoutIfNeeded()
        }
    }
}

// MARK: - DateBoxView

private final class DateBoxView: UIView {

    // MARK: - UI Components

    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [captionLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private var isActive = false

    // MARK: - Init

    init(caption: String) {
        super.init(frame: .zero)
        captionLabel.text = caption
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius12
        layer.borderWidth = WraithBorderWidth.hairline
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    private func setupLayout() {
        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space12),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space12),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyBorder(active: isActive)
    }

    // MARK: - Public

    func setDateText(_ text: String) {
        dateLabel.text = text
    }

    func setActive(_ active: Bool) {
        isActive = active
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4, options: [.curveEaseInOut]) {
            self.applyBorder(active: active)
            self.backgroundColor = active ? TripAccentTheme.accentSoftBackground : .wraithSurface
            self.transform = active ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
        }
    }

    private func applyBorder(active: Bool) {
        layer.borderWidth = active ? WraithBorderWidth.selected : WraithBorderWidth.hairline
        layer.borderColor = (active ? UIColor.wraithPrimary : .wraithOutlineVariant).cgColor
    }
}

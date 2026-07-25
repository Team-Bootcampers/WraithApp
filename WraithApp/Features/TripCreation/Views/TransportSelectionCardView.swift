//
//  TransportSelectionCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import SafariServices
import UIKit

final class TransportSelectionCardView: BaseCardView, TripCreationCardUpdating {

    // MARK: - UI Components

    private lazy var optionViews: [TransportOptionView] = TransportType.allCases.map { transportType in
        let optionView = TransportOptionView(transportType: transportType)
        optionView.translatesAutoresizingMaskIntoConstraints = false
        optionView.isUserInteractionEnabled = true
        optionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOption(_:))))
        return optionView
    }

    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: optionViews)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var ticketSearchRowView: TicketSearchRowView = {
        let view = TicketSearchRowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTicketSearchRow)))
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [optionsStackView, ticketSearchRowView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private let viewModel: TripCreationViewModel

    // MARK: - Init

    init(viewModel: TripCreationViewModel) {
        self.viewModel = viewModel
        super.init(title: "Nasıl gitmek istersin?", iconSystemName: "arrow.triangle.swap")
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
            optionsStackView.heightAnchor.constraint(equalToConstant: 72),
            ticketSearchRowView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Binding

    func update(with draft: TripCreationDraft) {
        optionViews.forEach { $0.setSelected($0.transportType == draft.selectedTransportType) }

        ticketSearchRowView.setIcon(systemName: draft.selectedTransportType.departureIconName)

        if draft.selectedDepartureCity == nil {
            ticketSearchRowView.setTitle("Bilet için kalkış şehrini de seçin")
        } else if draft.selectedCity == nil || draft.startDate == nil || draft.endDate == nil {
            ticketSearchRowView.setTitle("Bilet aramak için şehir ve tarih seçin")
        } else {
            ticketSearchRowView.setTitle("Bileti Görüntüle")
        }
    }

    // MARK: - Actions

    @objc private func didTapOption(_ gesture: UITapGestureRecognizer) {
        guard let optionView = gesture.view as? TransportOptionView else { return }
        viewModel.selectTransportType(optionView.transportType)
    }

    @objc private func didTapTicketSearchRow() {
        guard let presenter = ParentViewController else { return }

        guard let departureCity = viewModel.selectedDepartureCity?.name else {
            presentMissingDepartureAlert(from: presenter)
            return
        }

        guard
            let destinationCity = viewModel.selectedCity?.name,
            let startDate = viewModel.startDate,
            viewModel.endDate != nil
        else { return }

        guard let url = TicketSearchURLBuilder.url(
            for: viewModel.selectedTransportType,
            departureCity: departureCity,
            destinationCity: destinationCity,
            date: startDate
        ) else { return }

        presenter.present(SFSafariViewController(url: url), animated: true)
    }

    private func presentMissingDepartureAlert(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "Kalkış şehri gerekiyor",
            message: "Bilet aramak için önce yukarıdan kalkış şehrini seçmelisin.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        presenter.present(alert, animated: true)
    }
}

// MARK: - TransportOptionView

private final class TransportOptionView: UIView {

    // MARK: - UI Components

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .wraithOnSurface
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconContainerView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = WraithSpacing.space8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    let transportType: TransportType

    // MARK: - Init

    init(transportType: TransportType) {
        self.transportType = transportType
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: transportType.iconName)
        titleLabel.text = transportType.title
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(contentStackView)
        iconContainerView.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    // MARK: - Public

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
            self.iconContainerView.backgroundColor = selected ? TripAccentTheme.accent : .wraithSurfaceVariant
            self.iconImageView.tintColor = selected ? .wraithOnPrimary : .wraithOnSurface
            self.titleLabel.textColor = selected ? .wraithOnSurface : .wraithOnSurfaceVariant
            self.titleLabel.font = .systemFont(ofSize: 12, weight: selected ? .semibold : .regular)
            self.iconContainerView.transform = selected ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
        }
    }
}

// MARK: - TicketSearchRowView

private final class TicketSearchRowView: UIView {

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = TripAccentTheme.accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .wraithOnSurfaceVariant
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, chevronImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
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
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    // MARK: - Public

    func setIcon(systemName: String) {
        iconImageView.image = UIImage(systemName: systemName)
    }

    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}

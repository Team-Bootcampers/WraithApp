//
//  HotelSelectionCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class HotelSelectionCardView: BaseCardView, TripCreationCardUpdating {

    // MARK: - UI Components

    private let seeAllButton: UIButton

    private lazy var itemCardViews: [POIMiniCardView] = (0..<5).map { index in
        let view = POIMiniCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setCardBackground(.tertiarySystemGroupedBackground)
        view.onTap = { [weak self] in self?.didTapItemCard(at: index) }
        return view
    }

    private lazy var itemsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: itemCardViews)
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var itemsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    private let viewModel: TripCreationViewModel
    private var isCurrentlyVisible: Bool?

    // MARK: - Init

    init(viewModel: TripCreationViewModel) {
        self.viewModel = viewModel

        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Hepsini Gör"
        configuration.image = UIImage(systemName: "chevron.right")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 4
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = AppTheme.accent
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .medium)
            return outgoing
        }
        button.configuration = configuration
        self.seeAllButton = button

        super.init(title: "Konaklama Seçenekleri", accessoryView: button)

        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        setupLayout()
        update(with: viewModel.draft)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(itemsScrollView)
        contentContainerView.addSubview(placeholderLabel)
        itemsScrollView.addSubview(itemsStackView)

        NSLayoutConstraint.activate([
            itemsScrollView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            itemsScrollView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            itemsScrollView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            itemsScrollView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            itemsScrollView.heightAnchor.constraint(equalToConstant: 220),

            itemsStackView.topAnchor.constraint(equalTo: itemsScrollView.topAnchor),
            itemsStackView.leadingAnchor.constraint(equalTo: itemsScrollView.leadingAnchor),
            itemsStackView.trailingAnchor.constraint(equalTo: itemsScrollView.trailingAnchor),
            itemsStackView.bottomAnchor.constraint(equalTo: itemsScrollView.bottomAnchor),
            itemsStackView.heightAnchor.constraint(equalTo: itemsScrollView.heightAnchor),

            placeholderLabel.centerXAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: itemsScrollView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainerView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor)
        ])

        itemCardViews.forEach { $0.widthAnchor.constraint(equalTo: itemsScrollView.widthAnchor, multiplier: 0.7).isActive = true }
    }

    // MARK: - Binding

    func update(with draft: TripCreationDraft) {
        setCardVisible(draft.selectedCity != nil)
        guard draft.selectedCity != nil else { return }

        let hotels = draft.hotels

        if hotels.isEmpty {
            placeholderLabel.text = "Oteller yükleniyor..."
            placeholderLabel.isHidden = false
            itemsScrollView.isHidden = true
        } else {
            placeholderLabel.isHidden = true
            itemsScrollView.isHidden = false
        }

        seeAllButton.isEnabled = !hotels.isEmpty

        for (index, cardView) in itemCardViews.enumerated() {
            guard index < hotels.count else {
                cardView.isHidden = true
                continue
            }
            let hotel = hotels[index]
            cardView.isHidden = false
            cardView.configure(with: POIDisplayItem(
                id: hotel.id,
                name: hotel.name,
                rating: hotel.rating,
                priceText: "\(hotel.pricePerNight) \(hotel.currency)/gece",
                imageURL: hotel.imageURL,
                isSelected: draft.selectedHotelIDs.contains(hotel.id)
            ))
        }
    }

    // MARK: - Visibility

    private func setCardVisible(_ visible: Bool) {
        let isFirstCall = isCurrentlyVisible == nil
        guard isCurrentlyVisible != visible else { return }
        isCurrentlyVisible = visible

        guard !isFirstCall else {
            isHidden = !visible
            alpha = visible ? 1 : 0
            transform = .identity
            return
        }

        if visible {
            isHidden = false
            alpha = 0
            transform = CGAffineTransform(translationX: 0, y: 14).scaledBy(x: 0.96, y: 0.96)
        }

        let animationContainer = nearestScrollViewOrSelf

        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.alpha = visible ? 1 : 0
            self.transform = visible ? .identity : CGAffineTransform(translationX: 0, y: -8).scaledBy(x: 0.96, y: 0.96)
            animationContainer.layoutIfNeeded()
        } completion: { _ in
            guard self.isCurrentlyVisible == false else { return }
            self.isHidden = true
            self.transform = .identity
        }
    }

    // MARK: - Actions

    private func didTapItemCard(at index: Int) {
        guard index < viewModel.hotels.count else { return }
        viewModel.toggleHotelSelection(viewModel.hotels[index])
    }

    @objc private func didTapSeeAll() {
        guard let city = viewModel.selectedCity?.name, !viewModel.hotels.isEmpty else { return }
        guard let presenter = ParentViewController else { return }

        let allHotelsViewController = AllHotelsViewController(city: city, viewModel: viewModel)

        if let navigationController = presenter.navigationController {
            navigationController.pushViewController(allHotelsViewController, animated: true)
        } else {
            presenter.present(UINavigationController(rootViewController: allHotelsViewController), animated: true)
        }
    }
}

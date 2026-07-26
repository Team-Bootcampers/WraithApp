//
//  TripSummaryViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class TripSummaryViewController: UIViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var heroView = TripSummaryHeroView(stopCount: viewModel.stops.count)

    private lazy var totalCostView = TripSummaryTotalCostView(totalCost: viewModel.totalCost)

    private lazy var purchaseButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Biletleri Satın Al"
        configuration.image = UIImage(systemName: "creditcard.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: #selector(didTapPurchase), for: .touchUpInside)
        return button
    }()

    private lazy var planPDFButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Detaylı Gezi Planı"
        configuration.image = UIImage(systemName: "doc.text.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .wraithSecondary
        configuration.baseForegroundColor = .wraithOnSurface
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: #selector(didTapViewPlan), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    private let viewModel: TripSummaryViewModel
    private let publishingService: TripPublishingServiceProtocol
    private var authCoordinator: AuthCoordinator?

    // MARK: - Init

    init(viewModel: TripSummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seyahat Özeti"
        view.backgroundColor = .wraithBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Düzenle", style: .plain, target: self, action: #selector(didTapEditTrip))
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(heroView)

        for stop in viewModel.stops {
            let nights = viewModel.nightsCount(for: stop)
            let cost = viewModel.totalCost(for: stop)
            let stopCardView = TripStopSummaryCardView(stop: stop, nights: nights, cost: cost)
            contentStackView.addArrangedSubview(stopCardView)
        }

        contentStackView.addArrangedSubview(totalCostView)
        if viewModel.tripPlanPDFURL != nil {
            contentStackView.addArrangedSubview(planPDFButton)
        }
        contentStackView.addArrangedSubview(purchaseButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 14),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -14),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28)
        ])
    }

    // MARK: - Actions

    @objc private func didTapEditTrip() {
        let editViewController = TripCreationViewController(existingTrip: viewModel.trip)
        if let navigationController {
            navigationController.pushViewController(editViewController, animated: true)
        } else {
            present(UINavigationController(rootViewController: editViewController), animated: true)
        }
    }

    @objc private func didTapPurchase() {
        showAlert(title: "Bilet Satın Alındı", message: "Seyahatiniz için biletler başarıyla satın alındı.")
    }

    @objc private func didTapSaveTrip() {
        guard viewModel.saveBrowsedTrip() != nil else { return }
        saveTripButton.isEnabled = false
        saveTripButton.configuration?.title = "Kaydedildi"
        showAlert(title: "Kaydedildi", message: "Seyahat \"Seyahatlerim\" kısmına kaydedildi.")
    }

    @objc private func didTapMakePublic() {
        guard let savedTrip = viewModel.savedTrip else { return }

        guard UserSession.shared.isLoggedIn else {
            // `AuthCoordinator.onFinished` fires the same way whether the user logged in or
            // just closed the sheet, so re-checking the session afterward is the only way to
            // tell success from cancel — if it succeeded, resume this exact action.
            presentLogin { [weak self] in
                self?.didTapMakePublic()
            }
            return
        }

        if savedTrip.isPublic {
            confirmUnpublish(tripID: savedTrip.id)
        } else {
            presentPublishForm(tripID: savedTrip.id)
        }
    }

    // MARK: - Private

    private func presentLogin(onLoggedIn: @escaping () -> Void) {
        let coordinator = AuthCoordinator(presentingViewController: self)
        coordinator.onFinished = { [weak self] in
            self?.authCoordinator = nil
            if UserSession.shared.isLoggedIn {
                onLoggedIn()
            }
        }
        authCoordinator = coordinator
        coordinator.start()
    }

    private func publicButtonConfiguration(isPublic: Bool) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = isPublic ? "Herkese Açık Özelliğini Kapat" : "Herkese Aç"
        configuration.image = UIImage(systemName: isPublic ? "globe.slash.fill" : "globe")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = isPublic ? .wraithSurfaceVariant : .wraithSecondary
        configuration.baseForegroundColor = isPublic ? .wraithOnSurfaceVariant : .wraithOnSurface
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        return configuration
    }

    private func updatePublicButtonAppearance() {
        publicButton.configuration = publicButtonConfiguration(isPublic: viewModel.isPublic)
    }

    @objc private func didTapPurchase() {
        let alert = UIAlertController(
            title: "Bilet Satın Alındı",
            message: "Seyahatiniz için biletler başarıyla satın alındı.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TripSummaryHeroView

private final class TripSummaryHeroView: UIView {

    // MARK: - UI Components

    private lazy var gradientBackgroundView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "airplane.departure"))
        imageView.tintColor = .wraithOnPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Seyahat Özeti"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .wraithOnPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.wraithOnPrimary.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(stopCount: Int) {
        super.init(frame: .zero)
        subtitleLabel.text = stopCount == 1 ? "1 Durak Planlandı" : "\(stopCount) Durak Planlandı"
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        applyCardShadow()
        gradientBackgroundView.layer.cornerRadius = 20
        gradientBackgroundView.layer.masksToBounds = true
    }

    private func setupLayout() {
        addSubview(gradientBackgroundView)
        addSubview(iconImageView)
        addSubview(textStackView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 120),

            gradientBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - TripStopSummaryCardView

private final class TripStopSummaryCardView: BaseCardView {

    // MARK: - Init

    init(stop: TripStopSnapshot, nights: Int, cost: Int) {
        let cityTitle = stop.cityName.map { "\(stop.stopNumber). Durak — \($0)" } ?? "\(stop.stopNumber). Durak"
        super.init(title: cityTitle, iconSystemName: "mappin.and.ellipse")
        setupContent(stop: stop, nights: nights, cost: cost)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupContent(stop: TripStopSnapshot, nights: Int, cost: Int) {
        var sections: [UIView] = []

        var infoRows: [UIView] = []

        if let country = stop.country, let cityName = stop.cityName {
            let destinationText = "\(cityName), \(country.name)"
            let locationText = stop.departureCityName.map { "\($0) → \(destinationText)" } ?? destinationText
            infoRows.append(SummaryInfoRow(iconSystemName: "location.fill", text: locationText))
        }

        if let startDate = stop.startDate, let endDate = stop.endDate {
            let dateText = "\(Self.dateFormatter.string(from: startDate)) - \(Self.dateFormatter.string(from: endDate)) (\(nights) gece)"
            infoRows.append(SummaryInfoRow(iconSystemName: "calendar", text: dateText))
        }

        infoRows.append(SummaryInfoRow(iconSystemName: "person.2.fill", text: "\(stop.travelerCount) Kişi"))

        infoRows.append(SummaryInfoRow(iconSystemName: stop.transportType.departureIconName, text: stop.transportType.title))

        infoRows.append(SummaryInfoRow(iconSystemName: "turkishlirasign.circle.fill", text: "Bu Durağın Maliyeti: \(cost) TL", isEmphasized: true))

        let infoStack = UIStackView(arrangedSubviews: infoRows)
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        sections.append(infoStack)

        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        if !selectedHotels.isEmpty {
            sections.append(makePhotoRow(caption: "Konaklama", items: selectedHotels.map {
                POIDisplayItem(id: $0.id, name: $0.name, rating: $0.rating, priceText: "\($0.pricePerNight) \($0.currency)/gece", imageURL: $0.imageURL, isSelected: false)
            }))
        } else if let cheapestHotel = stop.hotels.min(by: { $0.pricePerNight < $1.pricePerNight }) {
            sections.append(makePhotoRow(caption: "Önerilen Otel (en uygun fiyat)", items: [
                POIDisplayItem(id: cheapestHotel.id, name: cheapestHotel.name, rating: cheapestHotel.rating, priceText: "\(cheapestHotel.pricePerNight) \(cheapestHotel.currency)/gece", imageURL: cheapestHotel.imageURL, isSelected: false)
            ]))
        }

        let selectedPlaces = stop.places.filter { stop.selectedPlaceIDs.contains($0.id) }
        if !selectedPlaces.isEmpty {
            sections.append(makePhotoRow(caption: "Gezilecek Yerler", items: selectedPlaces.map {
                POIDisplayItem(id: $0.id, name: $0.name, rating: $0.rating, priceText: nil, imageURL: $0.imageURL, isSelected: false)
            }))
        }

        let selectedRestaurants = stop.restaurants.filter { stop.selectedRestaurantIDs.contains($0.id) }
        if !selectedRestaurants.isEmpty {
            sections.append(makePhotoRow(caption: "Restoranlar", items: selectedRestaurants.map {
                POIDisplayItem(id: $0.id, name: $0.name, rating: $0.rating, priceText: nil, imageURL: $0.imageURL, isSelected: false)
            }))
        }

        let stack = UIStackView(arrangedSubviews: sections)
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }

    private func makePhotoRow(caption: String, items: [POIDisplayItem]) -> UIView {
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        captionLabel.textColor = .wraithOnSurfaceVariant
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let cardViews = items.map { item -> POIMiniCardView in
            let view = POIMiniCardView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setCardBackground(.wraithSurfaceVariant)
            view.configure(with: item)
            return view
        }

        let cardsStackView = UIStackView(arrangedSubviews: cardViews)
        cardsStackView.axis = .horizontal
        cardsStackView.spacing = 10
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(cardsStackView)

        // Only activate the width constraints now that each card view actually shares an
        // ancestor with `scrollView` (via `cardsStackView`) — doing this inside the `map`
        // above, before the views were attached to anything, crashed with "Unable to
        // activate constraint... no common ancestor".
        cardViews.forEach { $0.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.7).isActive = true }

        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 220),
            cardsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            cardsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            cardsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            cardsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            cardsStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        let containerStack = UIStackView(arrangedSubviews: [captionLabel, scrollView])
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        return containerStack
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}

// MARK: - SummaryInfoRow

private final class SummaryInfoRow: UIView {

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = TripAccentTheme.accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, textLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(iconSystemName: String, text: String, isEmphasized: Bool = false) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: iconSystemName)
        textLabel.text = text
        if isEmphasized {
            textLabel.font = .systemFont(ofSize: 15, weight: .bold)
            textLabel.textColor = TripAccentTheme.accent
        }
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}

// MARK: - TripSummaryTotalCostView

private final class TripSummaryTotalCostView: BaseCardView {

    // MARK: - UI Components

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .wraithPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(totalCost: Int) {
        super.init(title: "Tahmini Toplam Maliyet", iconSystemName: "turkishlirasign.circle.fill")
        amountLabel.text = "\(totalCost) TL"
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(amountLabel)
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor),
            amountLabel.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
}

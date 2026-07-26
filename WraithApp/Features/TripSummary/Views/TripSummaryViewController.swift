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

    private lazy var totalCostView: TripSummaryTotalCostView = {
        let view = TripSummaryTotalCostView(totalCost: viewModel.totalCost)
        view.onPurchaseTap = { [weak self] in self?.didTapPurchase() }
        return view
    }()

    private lazy var planPDFButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Detaylı Gezi Planı"
        configuration.image = UIImage(systemName: "doc.text.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .wraithSecondary
        configuration.baseForegroundColor = .wraithOnSecondary
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

    private lazy var generatePlanButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Detaylı Gezi Planı Oluştur"
        configuration.image = UIImage(systemName: "sparkles")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .wraithSecondary
        configuration.baseForegroundColor = .wraithOnSecondary
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: #selector(didTapGeneratePlan), for: .touchUpInside)
        return button
    }()

    private lazy var saveTripButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Seyahatlerime Kaydet"
        configuration.image = UIImage(systemName: "bookmark.fill")
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
        button.addTarget(self, action: #selector(didTapSaveTrip), for: .touchUpInside)
        return button
    }()

    private lazy var publicIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = TripAccentTheme.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapMakePublic), for: .touchUpInside)
        button.applyStandardPressAnimation()
        return button
    }()

    private lazy var editIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = TripAccentTheme.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapEditTrip), for: .touchUpInside)
        button.applyStandardPressAnimation()
        return button
    }()

    /// Wrapping both icons in one custom-view bar item (instead of two separate
    /// `UIBarButtonItem`s) is what makes the gap between them controllable — the system
    /// spacing between adjacent bar button items can't be tightened directly.
    private lazy var navigationBarActionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = WraithSpacing.space12
        stack.alignment = .center
        return stack
    }()

    private lazy var planGenerationLoadingView: TripPlanGenerationLoadingView = {
        let view = TripPlanGenerationLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var planGenerationOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(planGenerationLoadingView)
        NSLayoutConstraint.activate([
            planGenerationLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planGenerationLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planGenerationLoadingView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: WraithSpacing.space20),
            planGenerationLoadingView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -WraithSpacing.space20)
        ])
        return view
    }()

    // MARK: - Properties

    private let viewModel: TripSummaryViewModel
    private let publishingService: TripPublishingServiceProtocol
    private var authCoordinator: AuthCoordinator?

    // MARK: - Init

    init(viewModel: TripSummaryViewModel, publishingService: TripPublishingServiceProtocol = TripPublishingService()) {
        self.viewModel = viewModel
        self.publishingService = publishingService
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
        updateNavigationBarItems()
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(planGenerationOverlayView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(heroView)

        for stop in viewModel.stops {
            let nights = viewModel.nightsCount(for: stop)
            let cost = viewModel.totalCost(for: stop)
            let stopCardView = TripStopSummaryCardView(stop: stop, nights: nights, cost: cost)
            stopCardView.onBuyTicketTap = { [weak self] in
                self?.showAlert(title: "Bilet Alındı", message: "Biletin başarıyla satın alındı.")
            }
            stopCardView.onReserveHotelTap = { [weak self] in
                self?.showAlert(title: "Rezervasyon Yapıldı", message: "Otel rezervasyonun başarıyla tamamlandı.")
            }
            contentStackView.addArrangedSubview(stopCardView)
        }

        if !viewModel.stops.isEmpty {
            contentStackView.addArrangedSubview(totalCostView)
        }
        if viewModel.tripPlanPDFURL != nil {
            contentStackView.addArrangedSubview(planPDFButton)
        } else if viewModel.savedTrip != nil {
            contentStackView.addArrangedSubview(generatePlanButton)
        }
        if viewModel.canSaveBrowsedTrip {
            contentStackView.addArrangedSubview(saveTripButton)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 14),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -14),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -28),

            planGenerationOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            planGenerationOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            planGenerationOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            planGenerationOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Both actions moved from full-width buttons in the content to icon-only bar items —
    /// same functions (`didTapEditTrip` / `didTapMakePublic`), just relocated so the primary
    /// "Rezervasyonu Tamamla" CTA isn't competing with them for attention in the scroll body.
    private func updateNavigationBarItems() {
        navigationBarActionsStackView.arrangedSubviews.forEach {
            navigationBarActionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if viewModel.savedTrip != nil {
            updatePublicIconAppearance()
            navigationBarActionsStackView.addArrangedSubview(publicIconButton)
        }
        if !viewModel.stops.isEmpty {
            navigationBarActionsStackView.addArrangedSubview(editIconButton)
        }
        navigationItem.rightBarButtonItem = navigationBarActionsStackView.arrangedSubviews.isEmpty
            ? nil
            : UIBarButtonItem(customView: navigationBarActionsStackView)
    }

    // MARK: - Actions

    @objc private func didTapEditTrip() {
        guard let savedTrip = viewModel.savedTrip else { return }
        let editViewController = TripCreationViewController(existingTrip: savedTrip)
        if let navigationController {
            navigationController.pushViewController(editViewController, animated: true)
        } else {
            present(UINavigationController(rootViewController: editViewController), animated: true)
        }
    }

    @objc private func didTapViewPlan() {
        guard let url = viewModel.tripPlanPDFURL else { return }
        navigationController?.pushViewController(PDFViewerViewController(fileURL: url), animated: true)
    }

    @objc private func didTapGeneratePlan() {
        planGenerationOverlayView.isHidden = false
        planGenerationLoadingView.startAnimating()

        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.generateDetailedPlan()
                totalCostView.updateAmount(viewModel.totalCost)
                if let index = contentStackView.arrangedSubviews.firstIndex(of: generatePlanButton) {
                    contentStackView.removeArrangedSubview(generatePlanButton)
                    generatePlanButton.removeFromSuperview()
                    contentStackView.insertArrangedSubview(planPDFButton, at: index)
                }
                // The traveler just asked for this exact plan — show it immediately instead
                // of making them tap "Detaylı Gezi Planı" again to see what was generated.
                if let url = viewModel.tripPlanPDFURL {
                    navigationController?.pushViewController(PDFViewerViewController(fileURL: url), animated: true)
                }
            } catch {
                print("⚠️ TripPlanningService.generatePlanPDF failed: \(error)")
                let message = (error as? TripPlanningError)?.errorDescription ?? "Detaylı gezi planı oluşturulamadı: \(error.localizedDescription)"
                showAlert(title: "Bir Sorun Oluştu", message: message)
            }

            planGenerationLoadingView.stopAnimating()
            planGenerationOverlayView.isHidden = true
        }
    }

    @objc private func didTapPurchase() {
        showAlert(title: "Rezervasyon Tamamlandı", message: "Biletlerin ve konaklama rezervasyonun başarıyla tamamlandı.")
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
            confirmUnpublish()
        } else {
            presentPublishForm()
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

    private func updatePublicIconAppearance() {
        let isPublic = viewModel.isPublic
        // Same tint as `editIconButton` regardless of state — the icon shape alone (not a
        // color change) communicates public vs. private here.
        publicIconButton.setImage(UIImage(systemName: isPublic ? "globe.fill" : "globe"), for: .normal)
        publicIconButton.accessibilityLabel = isPublic ? "Herkese Açık Özelliğini Kapat" : "Herkese Aç"
    }

    private func presentPublishForm() {
        let formViewController = PublishTripFormViewController()
        formViewController.onSubmit = { [weak self, weak formViewController] title, description in
            formViewController?.dismiss(animated: true) {
                self?.publishTrip(title: title, description: description)
            }
        }
        present(UINavigationController(rootViewController: formViewController), animated: true)
    }

    private func confirmUnpublish() {
        let alert = UIAlertController(
            title: "Herkese Açıklığı Kapat",
            message: "Bu seyahat artık diğer kullanıcılar tarafından görüntülenemeyecek.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kapat", style: .destructive) { [weak self] _ in
            self?.unpublishTrip()
        })
        present(alert, animated: true)
    }

    /// The backend only learns about a trip once `ensureBackendTripId` creates it via
    /// `POST /trips` — this happens lazily here, the first time the user publishes, since
    /// there's no separate "sync to backend" step earlier in the flow.
    private func publishTrip(title: String, description: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let backendTripId = try await viewModel.ensureBackendTripId(using: publishingService)
                try await publishingService.publishTrip(tripID: backendTripId, title: title, description: description)
                viewModel.setPublic(true)
                updatePublicIconAppearance()
                showAlert(title: "Paylaşıldı", message: "Seyahatin herkese açık hale getirildi.")
            } catch {
                print("⚠️ TripPublishingService.publishTrip failed: \(error)")
                showAlert(title: "Bir Sorun Oluştu", message: "Seyahat paylaşılamadı: \(error.localizedDescription)")
            }
        }
    }

    private func unpublishTrip() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let backendTripId = try await viewModel.ensureBackendTripId(using: publishingService)
                try await publishingService.unpublishTrip(tripID: backendTripId)
                viewModel.setPublic(false)
                updatePublicIconAppearance()
                showAlert(title: "Kapatıldı", message: "Seyahat artık herkese açık değil.")
            } catch {
                print("⚠️ TripPublishingService.unpublishTrip failed: \(error)")
                showAlert(title: "Bir Sorun Oluştu", message: "İşlem tamamlanamadı: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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

    // MARK: - Properties

    var onBuyTicketTap: (() -> Void)?
    var onReserveHotelTap: (() -> Void)?

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

        let ticketRow = TicketPurchaseRowView(transportType: stop.transportType)
        ticketRow.onBuyTap = { [weak self] in self?.onBuyTicketTap?() }
        infoRows.append(ticketRow)

        infoRows.append(SummaryInfoRow(iconSystemName: "turkishlirasign.circle.fill", text: "Bu Durağın Maliyeti: \(cost) TL", isEmphasized: true))

        let infoStack = UIStackView(arrangedSubviews: infoRows)
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        sections.append(infoStack)

        let selectedHotels = stop.hotels.filter { stop.selectedHotelIDs.contains($0.id) }
        if !selectedHotels.isEmpty {
            sections.append(makePhotoRow(
                caption: "Konaklama",
                items: selectedHotels.map {
                    POIDisplayItem(id: $0.id, name: $0.name, rating: $0.rating, priceText: "\($0.pricePerNight) \($0.currency)/gece", imageURL: $0.imageURL, isSelected: false)
                },
                cardActionTitle: "Rezervasyon Yap",
                cardAction: { [weak self] in self?.onReserveHotelTap?() }
            ))
        } else if let cheapestHotel = stop.hotels.min(by: { $0.pricePerNight < $1.pricePerNight }) {
            sections.append(makePhotoRow(
                caption: "Önerilen Otel (en uygun fiyat)",
                items: [
                    POIDisplayItem(id: cheapestHotel.id, name: cheapestHotel.name, rating: cheapestHotel.rating, priceText: "\(cheapestHotel.pricePerNight) \(cheapestHotel.currency)/gece", imageURL: cheapestHotel.imageURL, isSelected: false)
                ],
                cardActionTitle: "Rezervasyon Yap",
                cardAction: { [weak self] in self?.onReserveHotelTap?() }
            ))
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

    private func makePhotoRow(caption: String, items: [POIDisplayItem], cardActionTitle: String? = nil, cardAction: (() -> Void)? = nil) -> UIView {
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        captionLabel.textColor = .wraithOnSurfaceVariant
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Bigger, showcase-style thumbnails (matching the selection carousels in Trip
        // Creation) instead of the old small crop — the extra room goes entirely to the
        // photo, not to the text rows below it. Each card (not the section header) carries
        // its own action button, since that's the actual hotel/place the action applies to.
        let cardViews = items.map { item -> POIMiniCardView in
            let view = POIMiniCardView(photoHeight: WraithSpacing.space200)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setCardBackground(.wraithSurfaceVariant)
            view.configure(with: item)
            view.setActionButton(title: cardActionTitle)
            view.onActionTap = cardAction
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
        cardViews.forEach { $0.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.72).isActive = true }

        // The per-card action button (when present) needs extra room below the price so it
        // doesn't get squeezed against the card's bottom edge.
        let cardsHeight: CGFloat = cardActionTitle == nil ? WraithSpacing.space280 : WraithSpacing.space320

        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: cardsHeight),
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

// MARK: - TicketPurchaseRowView

/// Replaces the plain transport `SummaryInfoRow` with one that also surfaces a mock starting
/// ticket price and a direct "Bilet Al" action, right where the traveler is already looking
/// at how they're getting there.
private final class TicketPurchaseRowView: UIView {

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
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var buyButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Bilet Al"
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: WraithSpacing.space8, leading: WraithSpacing.space14, bottom: WraithSpacing.space8, trailing: WraithSpacing.space14)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        button.applyStandardPressAnimation()
        return button
    }()

    private lazy var rowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, textStackView, buyButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onBuyTap: (() -> Void)?

    // MARK: - Init

    init(transportType: TransportType) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: transportType.departureIconName)
        titleLabel.text = transportType.title
        priceLabel.text = "Kişi başı min. \(Self.mockMinimumPrice(for: transportType)) TL"
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(rowStackView)
        NSLayoutConstraint.activate([
            rowStackView.topAnchor.constraint(equalTo: topAnchor),
            rowStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    // MARK: - Actions

    @objc private func didTapBuy() {
        onBuyTap?()
    }

    // MARK: - Private

    private static func mockMinimumPrice(for transportType: TransportType) -> Int {
        switch transportType {
        case .airplane: return 2250
        case .bus: return 850
        case .car: return 450
        }
    }
}

// MARK: - TripSummaryTotalCostView

private final class TripSummaryTotalCostView: BaseCardView {

    // MARK: - UI Components

    /// Sits next to the "Tahmini Toplam Maliyet" title itself (as the card header's
    /// accessory) instead of on its own row below — the money figure and its label read as
    /// one unit that way, and the card no longer needs its own currency-icon badge to say
    /// "this is about money" since the amount is right there in the header.
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .wraithPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Lives in the same card as the total cost, and its own title states that exact amount
    /// — so it reads as "this button pays this price" rather than two unrelated blocks.
    private lazy var purchaseButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "checkmark.seal.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(didTapPurchase), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    var onPurchaseTap: (() -> Void)?

    // MARK: - Init

    init(totalCost: Int) {
        super.init(title: "Tahmini Toplam Maliyet", accessoryView: amountLabel)
        updateAmount(totalCost)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func updateAmount(_ totalCost: Int) {
        let formattedAmount = Self.amountFormatter.string(from: NSNumber(value: totalCost)) ?? "\(totalCost)"
        amountLabel.text = "\(formattedAmount) TL"
        purchaseButton.configuration?.title = "\(formattedAmount) TL Öde ve Tamamla"
    }

    // MARK: - Private

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(purchaseButton)
        NSLayoutConstraint.activate([
            purchaseButton.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            purchaseButton.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            purchaseButton.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            purchaseButton.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func didTapPurchase() {
        onPurchaseTap?()
    }
}

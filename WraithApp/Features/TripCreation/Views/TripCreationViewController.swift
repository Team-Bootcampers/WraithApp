//
//  TripCreationViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

protocol TripCreationCardUpdating: AnyObject {
    func update(with draft: TripCreationDraft)
}

final class TripCreationViewController: UIViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var addStopCardView: AddStopCardView = {
        let view = AddStopCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap = { [weak self] in self?.didTapAddStop() }
        return view
    }()

    private lazy var saveButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var saveButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Seyahati Kaydet")
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()

    private lazy var itineraryLoadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.wraithBackground.withAlphaComponent(0.92)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .wraithPrimary
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Detaylı gezi planı hazırlanıyor..."
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: WraithSpacing.space16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space40),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space40)
        ])
        return view
    }()

    // MARK: - Properties

    var onTripSaved: ((SavedTrip) -> Void)?

    private var stopViewModels: [TripCreationViewModel] = []
    private var stopSectionViews: [StopSectionView] = []
    private let existingTrip: SavedTrip?
    private var initialStopSnapshots: [TripStopSnapshot] { existingTrip?.stops ?? [] }

    // MARK: - Init

    init(existingTrip: SavedTrip? = nil) {
        self.existingTrip = existingTrip
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = existingTrip == nil ? "Yeni Seyahat" : "Seyahati Düzenle"
        setupLayout()
        if initialStopSnapshots.isEmpty {
            addStop()
        } else {
            // Load quietly (no collapse animation) — this happens before the view is even
            // visible, so animating it would just be wasted work.
            initialStopSnapshots.forEach { addStop(prefillFrom: $0, animated: false) }
        }
        updateSaveButtonState()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(saveButtonContainerView)
        scrollView.addSubview(cardsStackView)
        saveButtonContainerView.addSubview(saveButton)
        view.addSubview(itineraryLoadingOverlayView)

        cardsStackView.addArrangedSubview(addStopCardView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButtonContainerView.topAnchor),

            cardsStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: WraithSpacing.space16),
            cardsStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: WraithSpacing.space14),
            cardsStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -WraithSpacing.space14),
            cardsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -WraithSpacing.space16),
            cardsStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -WraithSpacing.space28),

            saveButtonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            saveButtonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            saveButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            saveButton.topAnchor.constraint(equalTo: saveButtonContainerView.topAnchor, constant: WraithSpacing.space12),
            saveButton.leadingAnchor.constraint(equalTo: saveButtonContainerView.leadingAnchor, constant: WraithSpacing.space20),
            saveButton.trailingAnchor.constraint(equalTo: saveButtonContainerView.trailingAnchor, constant: -WraithSpacing.space20),
            saveButton.bottomAnchor.constraint(equalTo: saveButtonContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space12),

            itineraryLoadingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            itineraryLoadingOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itineraryLoadingOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itineraryLoadingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addStop(prefillFrom snapshot: TripStopSnapshot? = nil, animated: Bool = true) {
        let viewModel = TripCreationViewModel()
        stopViewModels.append(viewModel)

        let section = makeStopSection(stopNumber: stopViewModels.count, viewModel: viewModel)
        section.onDelete = { [weak self, weak viewModel] in
            guard let self, let viewModel else { return }
            self.removeStop(section: section, viewModel: viewModel)
        }

        if !stopSectionViews.isEmpty {
            stopSectionViews.forEach { $0.setExpanded(false, animated: animated) }
        }
        stopSectionViews.append(section)

        let insertIndex = cardsStackView.arrangedSubviews.count - 1
        cardsStackView.insertArrangedSubview(section, at: max(insertIndex, 0))

        if let snapshot {
            viewModel.loadStop(from: snapshot)
        }

        updateStopDeletability()
    }

    private func removeStop(section: StopSectionView, viewModel: TripCreationViewModel) {
        guard stopViewModels.count > 1, let index = stopViewModels.firstIndex(where: { $0 === viewModel }) else { return }

        stopViewModels.remove(at: index)
        stopSectionViews.removeAll { $0 === section }

        let animationContainer = section.nearestScrollViewOrSelf

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) {
            section.alpha = 0
            section.isHidden = true
            animationContainer.layoutIfNeeded()
        } completion: { _ in
            section.removeFromSuperview()
            self.renumberStops()
            self.updateStopDeletability()
            self.updateSaveButtonState()
        }
    }

    private func renumberStops() {
        for (index, section) in stopSectionViews.enumerated() {
            section.updateStopNumber(index + 1)
        }
    }

    private func updateStopDeletability() {
        let canDelete = stopSectionViews.count > 1
        stopSectionViews.forEach { $0.setDeletable(canDelete) }
    }

    /// Clears every stop back to a single blank one, so the "Yeni Seyahat" tab starts
    /// fresh the next time it's visited instead of still showing the trip that was just saved.
    private func resetForm() {
        stopSectionViews.forEach { $0.removeFromSuperview() }
        stopSectionViews.removeAll()
        stopViewModels.removeAll()

        addStop(animated: false)
        updateSaveButtonState()
        scrollView.setContentOffset(.zero, animated: false)
    }

    private func makeStopSection(stopNumber: Int, viewModel: TripCreationViewModel) -> StopSectionView {
        let cards: [UIView & TripCreationCardUpdating] = [
            CountryCityCardView(viewModel: viewModel),
            TravelerCountCardView(viewModel: viewModel),
            DateSelectionCardView(viewModel: viewModel),
            TransportSelectionCardView(viewModel: viewModel),
            HotelSelectionCardView(viewModel: viewModel),
            PlaceSelectionCardView(viewModel: viewModel),
            RestaurantSelectionCardView(viewModel: viewModel)
        ]

        let sectionView = StopSectionView(stopNumber: stopNumber, cardViews: cards)
        sectionView.translatesAutoresizingMaskIntoConstraints = false

        viewModel.addObserver { [weak self] draft in
            cards.forEach { $0.update(with: draft) }
            self?.updateSaveButtonState()
        }

        return sectionView
    }

    // MARK: - Save Button State

    private func updateSaveButtonState() {
        let isComplete = !stopViewModels.isEmpty && stopViewModels.allSatisfy { viewModel in
            viewModel.selectedCity != nil && viewModel.startDate != nil && viewModel.endDate != nil
        }
        saveButton.isEnabled = isComplete
        saveButton.alpha = isComplete ? 1 : 0.4
    }

    // MARK: - Actions

    private func didTapAddStop() {
        addStop()
        updateSaveButtonState()
    }

    @objc private func didTapSave() {
        let snapshots = stopViewModels.enumerated().map { index, viewModel -> TripStopSnapshot in
            TripStopSnapshot(
                stopNumber: index + 1,
                departureCityName: viewModel.selectedDepartureCity?.name,
                country: viewModel.selectedCountry,
                cityName: viewModel.selectedCity?.name,
                travelerCount: viewModel.travelerCount,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                transportType: viewModel.selectedTransportType,
                hotels: viewModel.hotels,
                selectedHotelIDs: Set(viewModel.hotels.filter { viewModel.isHotelSelected($0) }.map(\.id)),
                places: viewModel.places,
                selectedPlaceIDs: Set(viewModel.places.filter { viewModel.isPlaceSelected($0) }.map(\.id)),
                restaurants: viewModel.restaurants,
                selectedRestaurantIDs: Set(viewModel.restaurants.filter { viewModel.isRestaurantSelected($0) }.map(\.id))
            )
        }

        let savedTrip = SavedTrip(
            id: existingTrip?.id ?? UUID(),
            createdAt: existingTrip?.createdAt ?? Date(),
            stops: snapshots,
            tripPlanPDFFileName: existingTrip?.tripPlanPDFFileName
        )
        // Save immediately so the trip isn't lost even if the detailed-plan generation below
        // fails or the user leaves before it finishes.
        TripStore.shared.save(savedTrip)

        saveButton.isEnabled = false
        saveButton.alpha = 0.4
        itineraryLoadingOverlayView.isHidden = false

        Task { [weak self] in
            guard let self else { return }
            var finalTrip = savedTrip
            do {
                let fileName = try await TripPlanningService().generatePlanPDF(for: savedTrip)
                finalTrip.tripPlanPDFFileName = fileName
                TripStore.shared.save(finalTrip)
            } catch TripPlanningError.missingCharacterAnalysis {
                // Expected before onboarding is complete — trip stays saved without a PDF.
            } catch {
                print("TripPlanning generation failed: \(error)")
                presentPlanGenerationErrorAlert()
            }

            itineraryLoadingOverlayView.isHidden = true
            saveButton.isEnabled = true
            saveButton.alpha = 1

            if existingTrip != nil {
                // Editing an existing trip: pop back to "Seyahatlerim" (where this screen was
                // reached from) so it reloads with the just-saved data, instead of resetting
                // this instance in place — this instance is being discarded, not reused.
                navigationController?.popToRootViewController(animated: true)
            } else {
                resetForm()
                onTripSaved?(finalTrip)
            }
        }
    }

    private func presentPlanGenerationErrorAlert() {
        let alert = UIAlertController(
            title: "Bir Sorun Oluştu",
            message: "Detaylı gezi planı oluşturulamadı. Seyahatin kaydedildi, planı daha sonra tekrar deneyebilirsin.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

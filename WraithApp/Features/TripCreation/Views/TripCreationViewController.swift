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
        if existingTrip == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Temizle",
                style: .plain,
                target: self,
                action: #selector(didTapClear)
            )
        }
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
            saveButton.bottomAnchor.constraint(equalTo: saveButtonContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space12)
        ])
    }

    private func addStop(prefillFrom snapshot: TripStopSnapshot? = nil, animated: Bool = true) {
        let viewModel = TripCreationViewModel()

        // Chain stops together: a newly added stop departs from wherever the previous stop
        // arrived, so the user isn't re-picking a city they just selected. Skipped when
        // restoring a saved trip — the snapshot already carries its own departure city.
        if snapshot == nil, let previousCity = stopViewModels.last?.selectedCity {
            viewModel.selectDepartureCity(previousCity)
        }

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

    @objc private func didTapClear() {
        let alert = UIAlertController(
            title: "Tüm Seçimleri Temizle",
            message: "Girdiğin tüm durak bilgileri silinecek. Devam etmek istiyor musun?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Temizle", style: .destructive) { [weak self] _ in
            self?.resetForm()
        })
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alert, animated: true)
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
            isPublic: existingTrip?.isPublic ?? false,
            backendTripId: existingTrip?.backendTripId,
            tripPlanPDFFileName: existingTrip?.tripPlanPDFFileName,
            estimatedTotalCostAmount: existingTrip?.estimatedTotalCostAmount,
            estimatedTotalCostCurrency: existingTrip?.estimatedTotalCostCurrency,
            isPurchased: existingTrip?.isPurchased ?? false,
            hasPurchasedPlanAddOn: existingTrip?.hasPurchasedPlanAddOn ?? false
        )
        TripStore.shared.save(savedTrip)

        if existingTrip != nil {
            // Editing an existing trip: pop back to "Seyahatlerim" (where this screen was
            // reached from) so it reloads with the just-saved data, instead of resetting
            // this instance in place — this instance is being discarded, not reused.
            navigationController?.popToRootViewController(animated: true)
        } else {
            resetForm()
            onTripSaved?(savedTrip)
        }
    }
}

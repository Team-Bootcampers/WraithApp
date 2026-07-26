//
//  MyTripsViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// "Seyahatlerim" tab — lists trips the user has saved from the Trip Creation flow.
final class MyTripsViewController: UIViewController {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .wraithBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.contentInset = UIEdgeInsets(top: WraithSpacing.space16, left: 0, bottom: WraithSpacing.space16, right: 0)
        tableView.register(TripCardTableViewCell.self, forCellReuseIdentifier: TripCardTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    /// `backgroundView`-based centering (`tableView.backgroundView = ...`) relies on legacy
    /// `autoresizingMask` sizing, which never resolves correctly once the view has
    /// `translatesAutoresizingMaskIntoConstraints = false` — pinning it directly to `view`
    /// with real Auto Layout constraints (below, in `setupLayout`) keeps it correctly
    /// centered regardless of when it's shown.
    private lazy var emptyStateView = EmptyStateView(
        iconSystemName: "airplane",
        title: "Henüz seyahatin yok",
        subtitle: "\"Yeni Seyahat\" sekmesinden ilk seyahatini oluştur."
    )

    private var trips: [SavedTrip] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Seyahatlerim"
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: WraithSpacing.space24),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -WraithSpacing.space24)
        ])
    }

    private func reload() {
        trips = TripStore.shared.loadTrips()
        emptyStateView.isHidden = !trips.isEmpty
        tableView.reloadData()
    }

    /// A trip saved from Home now carries full stop data (see `TripSummaryViewModel.saveBrowsedTrip`),
    /// same as a manually-created one — so stops are always the source of truth here when
    /// present, and `browsedTripPreview` is only a fallback for the rare case a trip somehow
    /// has none (or supplies extras, like `rating`, that stops don't carry at all).
    private func title(for trip: SavedTrip) -> String {
        let cityNames = trip.stops.compactMap { $0.cityName }
        if !cityNames.isEmpty { return cityNames.joined(separator: " → ") }
        if let preview = trip.browsedTripPreview { return preview.title }
        return "Seyahat"
    }

    private func subtitle(for trip: SavedTrip) -> String {
        if let start = trip.stops.first?.startDate, let end = trip.stops.last?.endDate {
            return "\(Self.dateFormatter.string(from: start)) - \(Self.dateFormatter.string(from: end))"
        }
        if let preview = trip.browsedTripPreview {
            return "\(preview.durationText) · \(preview.price) \(preview.currency)"
        }
        return "Seyahat"
    }

    private func icon(for trip: SavedTrip) -> String {
        if let transportType = trip.stops.first?.transportType { return transportType.iconName }
        return trip.browsedTripPreview != nil ? "map.fill" : "airplane"
    }

    private func chips(for trip: SavedTrip) -> [TripCardView.Chip] {
        var chips: [TripCardView.Chip] = []

        if !trip.stops.isEmpty {
            if let travelerCount = trip.stops.first?.travelerCount, travelerCount > 0 {
                let text = travelerCount == 1 ? "1 kişi" : "\(travelerCount) kişi"
                chips.append(TripCardView.Chip(icon: "person.2.fill", text: text))
            }
            let stopText = trip.stops.count == 1 ? "1 durak" : "\(trip.stops.count) durak"
            chips.append(TripCardView.Chip(icon: "mappin.and.ellipse", text: stopText))

            if let start = trip.stops.first?.startDate, let end = trip.stops.last?.endDate {
                // Every stop's own date range is contiguous with the next, so the first
                // stop's start to the last stop's end covers the whole trip.
                let days = max(Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0, 0) + 1
                chips.append(TripCardView.Chip(icon: "calendar", text: days == 1 ? "1 gün" : "\(days) gün"))
            }
            // The AI-generated estimate (`estimatedTotalCostAmount`) only exists once a
            // detailed plan PDF has been generated, which left most trips with no price chip
            // at all — falling back to the same locally-computed sum TripSummaryViewModel
            // uses means every trip with stops shows a price consistently.
            let amount = TripSummaryViewModel(trip: trip).totalCost
            if amount > 0 {
                let currency = trip.estimatedTotalCostCurrency ?? trip.stops.first?.hotels.first?.currency ?? "TL"
                chips.append(TripCardView.Chip(icon: "banknote.fill", text: "\(amount) \(currency)"))
            }
        } else if let preview = trip.browsedTripPreview {
            chips.append(TripCardView.Chip(icon: "calendar", text: preview.durationText))
            chips.append(TripCardView.Chip(icon: "banknote.fill", text: "\(preview.price) \(preview.currency)"))
        }

        return chips
    }
}

// MARK: - UITableViewDataSource

extension MyTripsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripCardTableViewCell.reuseIdentifier, for: indexPath) as? TripCardTableViewCell else {
            return UITableViewCell()
        }
        let trip = trips[indexPath.row]
        cell.configure(icon: icon(for: trip), title: title(for: trip), subtitle: subtitle(for: trip), chips: chips(for: trip)) { [weak self] in
            self?.showSummary(for: trip)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyTripsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.deleteTrip(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        TripStore.shared.remove(trip.id)
        trips.remove(at: indexPath.row)

        if trips.isEmpty {
            tableView.reloadData()
            emptyStateView.isHidden = false
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private func showSummary(for trip: SavedTrip) {
        let summaryViewModel = TripSummaryViewModel(trip: trip)
        let summaryViewController = TripSummaryViewController(viewModel: summaryViewModel)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

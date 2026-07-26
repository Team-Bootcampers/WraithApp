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

    private let emptyIconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius38
        return view
    }()

    private let emptyIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "airplane"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Henüz seyahatin yok"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnSurface
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\"Yeni Seyahat\" sekmesinden ilk seyahatini oluştur."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var emptyStateView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        emptyIconContainerView.addSubview(emptyIconImageView)
        [emptyIconContainerView, emptyTitleLabel, emptySubtitleLabel].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            emptyIconContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -WraithSpacing.space60),
            emptyIconContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emptyIconContainerView.widthAnchor.constraint(equalToConstant: 76),
            emptyIconContainerView.heightAnchor.constraint(equalToConstant: 76),

            emptyIconImageView.centerXAnchor.constraint(equalTo: emptyIconContainerView.centerXAnchor),
            emptyIconImageView.centerYAnchor.constraint(equalTo: emptyIconContainerView.centerYAnchor),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 34),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 34),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconContainerView.bottomAnchor, constant: WraithSpacing.space20),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: WraithSpacing.space8),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: WraithSpacing.space24),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -WraithSpacing.space24)
        ])

        return container
    }()

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
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func reload() {
        trips = TripStore.shared.loadTrips()
        tableView.backgroundView = trips.isEmpty ? emptyStateView : nil
        tableView.reloadData()
    }

    private func title(for trip: SavedTrip) -> String {
        if let preview = trip.browsedTripPreview { return preview.title }

        let cityNames = trip.stops.compactMap { $0.cityName }
        guard !cityNames.isEmpty else { return "Seyahat" }
        return cityNames.joined(separator: " → ")
    }

    private func subtitle(for trip: SavedTrip) -> String {
        if let preview = trip.browsedTripPreview {
            return "\(preview.durationText) · \(preview.price) \(preview.currency)"
        }

        guard
            let start = trip.stops.first?.startDate,
            let end = trip.stops.last?.endDate
        else {
            return "Seyahat"
        }
        return "\(Self.dateFormatter.string(from: start)) - \(Self.dateFormatter.string(from: end))"
    }

    private func icon(for trip: SavedTrip) -> String {
        if trip.browsedTripPreview != nil { return "map.fill" }
        return trip.stops.first?.transportType.iconName ?? "airplane"
    }

    private func chips(for trip: SavedTrip) -> [TripCardView.Chip] {
        var chips: [TripCardView.Chip] = []

        if let preview = trip.browsedTripPreview {
            chips.append(TripCardView.Chip(icon: "star.fill", text: String(format: "%.1f (%d)", preview.rating, preview.reviewCount)))
            chips.append(TripCardView.Chip(icon: "calendar", text: preview.durationText))
            chips.append(TripCardView.Chip(icon: "banknote.fill", text: "\(preview.price) \(preview.currency)"))
        } else {
            if let travelerCount = trip.stops.first?.travelerCount, travelerCount > 0 {
                let text = travelerCount == 1 ? "1 kişi" : "\(travelerCount) kişi"
                chips.append(TripCardView.Chip(icon: "person.2.fill", text: text))
            }
            if !trip.stops.isEmpty {
                let text = trip.stops.count == 1 ? "1 durak" : "\(trip.stops.count) durak"
                chips.append(TripCardView.Chip(icon: "mappin.and.ellipse", text: text))
            }
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
            if !trip.stops.isEmpty {
                let amount = TripSummaryViewModel(trip: trip).totalCost
                if amount > 0 {
                    let currency = trip.estimatedTotalCostCurrency ?? trip.stops.first?.hotels.first?.currency ?? "TL"
                    chips.append(TripCardView.Chip(icon: "banknote.fill", text: "\(amount) \(currency)"))
                }
            }
        }

        if trip.isPublic {
            chips.append(TripCardView.Chip(icon: "globe", text: "Herkese Açık"))
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
            tableView.backgroundView = emptyStateView
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

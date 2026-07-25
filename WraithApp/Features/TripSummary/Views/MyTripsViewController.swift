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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let tripsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        return stack
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
            emptyIconContainerView.topAnchor.constraint(equalTo: container.topAnchor),
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
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -WraithSpacing.space24),
            emptySubtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }()

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
        view.addSubview(scrollView)
        scrollView.addSubview(tripsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tripsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: WraithSpacing.space16),
            tripsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: WraithSpacing.space24),
            tripsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -WraithSpacing.space24),
            tripsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -WraithSpacing.space24),
            tripsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -WraithSpacing.space24 * 2)
        ])
    }

    private func reload() {
        tripsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let trips = TripStore.shared.loadTrips()
        guard !trips.isEmpty else {
            tripsStackView.addArrangedSubview(emptyStateView)
            NSLayoutConstraint.activate([
                emptyStateView.topAnchor.constraint(equalTo: tripsStackView.topAnchor, constant: WraithSpacing.space80)
            ])
            return
        }

        for trip in trips {
            let card = TripCardView()
            card.configure(title: title(for: trip), subtitle: subtitle(for: trip))
            card.addTarget(self, action: #selector(didTapTrip(_:)), for: .touchUpInside)
            card.tag = trips.firstIndex(where: { $0.id == trip.id }) ?? 0
            tripsStackView.addArrangedSubview(card)
        }
    }

    private func title(for trip: SavedTrip) -> String {
        let cityNames = trip.stops.compactMap { $0.cityName }
        guard !cityNames.isEmpty else { return "Seyahat" }
        return cityNames.joined(separator: " → ")
    }

    private func subtitle(for trip: SavedTrip) -> String {
        let stopCountText = trip.stops.count == 1 ? "1 durak" : "\(trip.stops.count) durak"
        guard
            let start = trip.stops.first?.startDate,
            let end = trip.stops.last?.endDate
        else {
            return stopCountText
        }
        let dateText = "\(Self.dateFormatter.string(from: start)) - \(Self.dateFormatter.string(from: end))"
        return "\(stopCountText) · \(dateText)"
    }

    @objc private func didTapTrip(_ sender: TripCardView) {
        let trips = TripStore.shared.loadTrips()
        guard trips.indices.contains(sender.tag) else { return }
        let summaryViewModel = TripSummaryViewModel(trip: trips[sender.tag])
        let summaryViewController = TripSummaryViewController(viewModel: summaryViewModel)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

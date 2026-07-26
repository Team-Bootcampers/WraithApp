//
//  HomeViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - UI Components

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Seyahat ara"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var sortButtons: [SortFilterButton] = PopularTripSortOption.allCases.map { option in
        let button = SortFilterButton(option: option)
        button.addTarget(self, action: #selector(didTapSortButton(_:)), for: .touchUpInside)
        return button
    }

    /// Absorbs the row's leftover width so `.fill` distribution keeps the buttons packed
    /// together with a fixed gap instead of `.equalSpacing` spreading that gap out to fill
    /// the stack's full (header-forced) width.
    private lazy var sortButtonsTrailingSpacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var sortButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: sortButtons + [sortButtonsTrailingSpacerView])
        stack.axis = .horizontal
        stack.spacing = WraithSpacing.space8
        stack.distribution = .fill
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchBar, sortButtonsStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .wraithBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PopularTripCell.self, forCellReuseIdentifier: PopularTripCell.reuseIdentifier)
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Sonuç bulunamadı"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    var onRequestRetakeOnboarding: (() -> Void)?

    private let viewModel: HomeViewModel

    // MARK: - Init

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Popüler Seyahatler"
        setupLayout()
        bindViewModel()
        viewModel.start()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(headerStackView)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)

        sortButtons.first?.isSelected = true

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: WraithSpacing.space8),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space16),

            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: WraithSpacing.space8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: tableView.topAnchor, constant: WraithSpacing.space40),

            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: WraithSpacing.space40),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: WraithSpacing.space20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -WraithSpacing.space20)
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()

            if self.viewModel.isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
            self.emptyStateLabel.isHidden = self.viewModel.isLoading || !self.viewModel.trips.isEmpty
        }

        // Scoped to a single row so toggling one card's favorite state never touches the
        // visuals of any other on-screen cell.
        viewModel.onFavoriteToggled = { [weak self] tripID in
            guard let self, let index = self.viewModel.trips.firstIndex(where: { $0.id == tripID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PopularTripCell else { return }
            cell.setFavorite(self.viewModel.trips[index].isFavorite)
        }
    }

    // MARK: - Actions

    @objc private func didTapSortButton(_ sender: SortFilterButton) {
        sortButtons.forEach { $0.isSelected = ($0 === sender) }
        viewModel.selectSortOption(sender.option)
    }

    @objc private func didPullToRefresh() {
        viewModel.pullToRefresh { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopularTripCell.reuseIdentifier, for: indexPath) as! PopularTripCell
        let trip = viewModel.trips[indexPath.row]
        cell.configure(with: trip)
        cell.onFavoriteTap = { [weak self] in self?.viewModel.toggleFavorite(for: trip) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trip = viewModel.trips[indexPath.row]
        let preview = BrowsedTripPreview(
            id: trip.id,
            title: trip.title,
            description: trip.description,
            imageURL: trip.imageURL,
            rating: trip.rating,
            reviewCount: trip.reviewCount,
            durationInDays: trip.durationInDays,
            price: trip.price,
            currency: trip.currency,
            stops: trip.stops
        )
        let summaryViewModel = TripSummaryViewModel(browsedTripPreview: preview)
        navigationController?.pushViewController(TripSummaryViewController(viewModel: summaryViewModel), animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextDidChange(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

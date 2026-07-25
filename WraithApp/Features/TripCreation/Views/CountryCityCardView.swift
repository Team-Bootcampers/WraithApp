//
//  CountryCityCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class CountryCityCardView: BaseCardView, TripCreationCardUpdating {

    // MARK: - UI Components

    private lazy var countryRow: SelectionRowView = {
        let row = SelectionRowView(showsFlag: true)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCountryRow)))
        return row
    }()

    private lazy var cityRow: SelectionRowView = {
        let row = SelectionRowView(showsFlag: false)
        row.translatesAutoresizingMaskIntoConstraints = false
        row.setEnabled(false)
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCityRow)))
        return row
    }()

    private lazy var rowsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [countryRow, cityRow])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    private let viewModel: TripCreationViewModel
    private var loadedCountries: [Country] = []
    private var loadedCities: [City] = []
    private weak var presentedListController: SelectionListViewController?

    // MARK: - Init

    init(viewModel: TripCreationViewModel) {
        self.viewModel = viewModel
        super.init(title: "Nereye gitmek istersin?", iconSystemName: "globe")
        setupLayout()
        update(with: viewModel.draft)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentContainerView.addSubview(rowsStackView)
        NSLayoutConstraint.activate([
            rowsStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            rowsStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            rowsStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            rowsStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            countryRow.heightAnchor.constraint(equalToConstant: 52),
            cityRow.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Binding

    func update(with draft: TripCreationDraft) {
        if let country = draft.selectedCountry {
            countryRow.setTitle(country.name, isPlaceholder: false)
            countryRow.setFlag(url: country.flagURL)
            cityRow.setEnabled(true)
        } else {
            countryRow.setTitle("Ülke seç", isPlaceholder: true)
            countryRow.setFlag(url: nil)
            cityRow.setEnabled(false)
        }

        if let city = draft.selectedCity {
            cityRow.setTitle(city.name, isPlaceholder: false)
        } else {
            cityRow.setTitle("Şehir seç", isPlaceholder: true)
        }
    }

    // MARK: - Actions

    @objc private func didTapCountryRow() {
        presentSelectionList(title: "Ülke Seç") { [weak self] item in
            guard let self, let country = self.loadedCountries.first(where: { $0.name == item.title }) else { return }
            self.viewModel.selectCountry(country)
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let countries = try await self.viewModel.loadCountries()
                self.loadedCountries = countries
                self.presentedListController?.setItems(countries.map { SelectionListViewController.Item(title: $0.name, flagURL: $0.flagURL) })
            } catch {
                self.presentedListController?.setItems([])
            }
            self.presentedListController?.setLoading(false)
        }
    }

    @objc private func didTapCityRow() {
        guard let country = viewModel.selectedCountry else { return }

        presentSelectionList(title: "Şehir Seç") { [weak self] item in
            guard let self, let city = self.loadedCities.first(where: { $0.name == item.title }) else { return }
            self.viewModel.selectCity(city)
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let cities = try await self.viewModel.loadCities(for: country)
                self.loadedCities = cities
                self.presentedListController?.setItems(cities.map { SelectionListViewController.Item(title: $0.name, flagURL: nil) })
            } catch {
                self.presentedListController?.setItems([])
            }
            self.presentedListController?.setLoading(false)
        }
    }

    private func presentSelectionList(title: String, onSelect: @escaping (SelectionListViewController.Item) -> Void) {
        guard let presenter = ParentViewController else { return }

        let listController = SelectionListViewController(listTitle: title)
        listController.onSelect = onSelect
        listController.setLoading(true)
        presentedListController = listController

        let navigationController = UINavigationController(rootViewController: listController)
        presenter.present(navigationController, animated: true)
    }
}

// MARK: - SelectionRowView

private final class SelectionRowView: UIView {

    // MARK: - UI Components

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [flagImageView, titleLabel, chevronImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(showsFlag: Bool) {
        super.init(frame: .zero)
        flagImageView.isHidden = !showsFlag
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .tertiarySystemGroupedBackground
        layer.cornerRadius = 12
    }

    private func setupLayout() {
        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 26),
            flagImageView.heightAnchor.constraint(equalToConstant: 18),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    // MARK: - Public

    func setTitle(_ text: String, isPlaceholder: Bool) {
        titleLabel.text = text
        titleLabel.textColor = isPlaceholder ? .secondaryLabel : .label
    }

    func setFlag(url: URL?) {
        flagImageView.setImage(from: url)
    }

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1 : 0.5
    }
}

// MARK: - SelectionListViewController

private final class SelectionListViewController: UIViewController {

    struct Item {
        let title: String
        let flagURL: URL?
    }

    // MARK: - UI Components

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Ara"
        return controller
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(SelectionItemCell.self, forCellReuseIdentifier: SelectionItemCell.reuseIdentifier)
        return tableView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Properties

    var onSelect: ((Item) -> Void)?

    private var allItems: [Item] = []
    private var filteredItems: [Item] = []
    private let listTitle: String

    // MARK: - Init

    init(listTitle: String) {
        self.listTitle = listTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = listTitle
        view.backgroundColor = .systemGroupedBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kapat", style: .plain, target: self, action: #selector(didTapClose))
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Public

    func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        tableView.isHidden = isLoading
    }

    func setItems(_ items: [Item]) {
        allItems = items
        filteredItems = items
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SelectionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionItemCell.reuseIdentifier, for: indexPath) as! SelectionItemCell
        cell.configure(with: filteredItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        let onSelect = onSelect
        dismiss(animated: true) {
            onSelect?(item)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SelectionListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filteredItems = query.isEmpty
            ? allItems
            : allItems.filter { $0.title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
        tableView.reloadData()
    }
}

// MARK: - SelectionItemCell

private final class SelectionItemCell: UITableViewCell {

    static let reuseIdentifier = "SelectionItemCell"

    // MARK: - UI Components

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        contentView.addSubview(flagImageView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            flagImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 28),
            flagImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        flagImageView.setImage(from: nil)
        titleLabel.text = nil
    }

    // MARK: - Public

    func configure(with item: SelectionListViewController.Item) {
        titleLabel.text = item.title
        flagImageView.isHidden = item.flagURL == nil
        flagImageView.setImage(from: item.flagURL)
    }
}

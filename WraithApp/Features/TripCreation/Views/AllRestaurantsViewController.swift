//
//  AllRestaurantsViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class AllRestaurantsViewController: UIViewController {

    // MARK: - UI Components

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = WraithSpacing.space12
        layout.minimumLineSpacing = WraithSpacing.space18
        layout.sectionInset = UIEdgeInsets(top: WraithSpacing.space18, left: WraithSpacing.space16, bottom: WraithSpacing.space18, right: WraithSpacing.space16)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        // Clear so the view's own background (`wraithSurface`, matching the "Restoranlar"
        // card) shows through directly instead of the collection view painting its own
        // opaque fill on top.
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(POIGridCell.self, forCellWithReuseIdentifier: POIGridCell.reuseIdentifier)
        return collectionView
    }()

    // MARK: - Properties

    private let city: String
    private let viewModel: TripCreationViewModel
    private var stateObserverID: UUID?
    private var lastRestaurantIDs: [String] = []

    // MARK: - Init

    init(city: String, viewModel: TripCreationViewModel) {
        self.city = city
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let stateObserverID {
            viewModel.removeObserver(stateObserverID)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(city) Restoranları"
        view.backgroundColor = .wraithSurface
        setupLayout()
        bindViewModel()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateItemSize() {
        let columns: CGFloat = 2
        let horizontalInsets = collectionViewLayout.sectionInset.left + collectionViewLayout.sectionInset.right
        let interItemSpacing = collectionViewLayout.minimumInteritemSpacing * (columns - 1)
        let availableWidth = collectionView.bounds.width - horizontalInsets - interItemSpacing
        let itemWidth = max(floor(availableWidth / columns), 0)
        collectionViewLayout.itemSize = CGSize(width: itemWidth, height: 210)
    }

    // MARK: - Binding

    private func bindViewModel() {
        lastRestaurantIDs = viewModel.restaurants.map(\.id)
        stateObserverID = viewModel.addObserver { [weak self] draft in
            guard let self else { return }
            // See `AllHotelsViewController`'s equivalent observer — selection toggles are
            // handled per-cell in `onTap`, so only reload when the restaurant list itself
            // changed.
            let currentIDs = draft.restaurants.map(\.id)
            guard currentIDs != self.lastRestaurantIDs else { return }
            self.lastRestaurantIDs = currentIDs
            self.collectionView.reloadData()
        }
    }

    private func displayItem(for restaurant: Restaurant) -> POIDisplayItem {
        POIDisplayItem(
            id: restaurant.id,
            name: restaurant.name,
            rating: restaurant.rating,
            priceText: nil,
            imageURL: restaurant.imageURL,
            isSelected: viewModel.isRestaurantSelected(restaurant)
        )
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension AllRestaurantsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.restaurants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: POIGridCell.reuseIdentifier, for: indexPath) as! POIGridCell
        let restaurant = viewModel.restaurants[indexPath.item]
        cell.cardView.configure(with: displayItem(for: restaurant))
        cell.cardView.onTap = { [weak self, weak cell] in
            guard let self else { return }
            self.viewModel.toggleRestaurantSelection(restaurant)
            cell?.cardView.configure(with: self.displayItem(for: restaurant))
        }
        return cell
    }
}

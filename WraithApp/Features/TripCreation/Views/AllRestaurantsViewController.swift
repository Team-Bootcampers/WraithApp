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
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemGroupedBackground
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
        view.backgroundColor = .systemGroupedBackground
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
        stateObserverID = viewModel.addObserver { [weak self] _ in
            self?.collectionView.reloadData()
        }
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
        cell.cardView.configure(with: POIDisplayItem(
            id: restaurant.id,
            name: restaurant.name,
            rating: restaurant.rating,
            priceText: nil,
            imageURL: restaurant.imageURL,
            isSelected: viewModel.isRestaurantSelected(restaurant)
        ))
        cell.cardView.onTap = { [weak self] in
            self?.viewModel.toggleRestaurantSelection(restaurant)
        }
        return cell
    }
}

//
//  AllHotelsViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class AllHotelsViewController: UIViewController {

    // MARK: - UI Components

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = WraithSpacing.space12
        layout.minimumLineSpacing = WraithSpacing.space16
        layout.sectionInset = UIEdgeInsets(top: WraithSpacing.space16, left: WraithSpacing.space16, bottom: WraithSpacing.space16, right: WraithSpacing.space16)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .wraithBackground
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
        title = "\(city) Otelleri"
        view.backgroundColor = .wraithBackground
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

extension AllHotelsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.hotels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: POIGridCell.reuseIdentifier, for: indexPath) as! POIGridCell
        let hotel = viewModel.hotels[indexPath.item]
        cell.cardView.configure(with: POIDisplayItem(
            id: hotel.id,
            name: hotel.name,
            rating: hotel.rating,
            priceText: "\(hotel.pricePerNight) \(hotel.currency)/gece",
            imageURL: hotel.imageURL,
            isSelected: viewModel.isHotelSelected(hotel)
        ))
        cell.cardView.onTap = { [weak self] in
            self?.viewModel.toggleHotelSelection(hotel)
        }
        return cell
    }
}

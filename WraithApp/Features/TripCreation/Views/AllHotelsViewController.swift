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
        layout.minimumLineSpacing = WraithSpacing.space18
        layout.sectionInset = UIEdgeInsets(top: WraithSpacing.space18, left: WraithSpacing.space16, bottom: WraithSpacing.space18, right: WraithSpacing.space16)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        // Clear so the view's own background (`wraithSurface`, matching the "Konaklama
        // Seçenekleri" card) shows through directly instead of the collection view
        // painting its own opaque fill on top.
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
    private var lastHotelIDs: [String] = []

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
        lastHotelIDs = viewModel.hotels.map(\.id)
        stateObserverID = viewModel.addObserver { [weak self] draft in
            guard let self else { return }
            // A selection toggle also fires this observer (it's a mutation of the same
            // draft), but that's handled per-cell in `onTap` below — reloading the whole
            // collection view here on every toggle used to make every visible card replay
            // its selection animation, not just the one that was tapped. Only reload when
            // the hotel list itself actually changed (e.g. a new city was picked).
            let currentIDs = draft.hotels.map(\.id)
            guard currentIDs != self.lastHotelIDs else { return }
            self.lastHotelIDs = currentIDs
            self.collectionView.reloadData()
        }
    }

    private func displayItem(for hotel: Hotel) -> POIDisplayItem {
        POIDisplayItem(
            id: hotel.id,
            name: hotel.name,
            rating: hotel.rating,
            priceText: "\(hotel.pricePerNight) \(hotel.currency)/gece",
            imageURL: hotel.imageURL,
            isSelected: viewModel.isHotelSelected(hotel)
        )
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
        cell.cardView.configure(with: displayItem(for: hotel))
        cell.cardView.onTap = { [weak self, weak cell] in
            guard let self else { return }
            self.viewModel.toggleHotelSelection(hotel)
            // Reconfigure just this cell directly instead of going through the broader
            // observer, so only the card that was actually tapped animates.
            cell?.cardView.configure(with: self.displayItem(for: hotel))
        }
        return cell
    }
}

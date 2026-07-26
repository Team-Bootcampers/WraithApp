//
//  POIGridCell.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class POIGridCell: UICollectionViewCell {

    static let reuseIdentifier = "POIGridCell"

    // MARK: - UI Components

    let cardView = POIMiniCardView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.onTap = nil
    }
}

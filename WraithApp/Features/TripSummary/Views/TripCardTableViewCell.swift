//
//  TripCardTableViewCell.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Wraps `TripCardView` in a table row so "Seyahatlerim" can offer native swipe-to-delete.
final class TripCardTableViewCell: UITableViewCell {

    static let reuseIdentifier = "TripCardTableViewCell"

    private let cardView = TripCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.configure(icon: "airplane", title: "", subtitle: "", chips: [])
    }

    func configure(icon: String, title: String, subtitle: String, chips: [TripCardView.Chip], onTap: @escaping () -> Void) {
        cardView.configure(icon: icon, title: title, subtitle: subtitle, chips: chips)
        cardView.removeTarget(nil, action: nil, for: .touchUpInside)
        cardView.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
    }
}

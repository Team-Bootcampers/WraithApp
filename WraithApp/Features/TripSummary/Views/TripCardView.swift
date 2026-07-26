//
//  TripCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Card row used on the "Seyahatlerim" list to summarize one saved trip.
final class TripCardView: UIControl {

    struct Chip {
        let icon: String
        let text: String
    }

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius16
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "airplane"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 1
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithOnSurfaceVariant
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// Horizontally scrollable so an arbitrary number of chips (travelers, transport, cost,
    /// visibility, rating...) never gets clipped or forces the card to overflow its width.
    private let chipsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let chipsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = WraithSpacing.space16
        stack.alignment = .center
        return stack
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        return stack
    }()

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(icon: String, title: String, subtitle: String, chips: [Chip]) {
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        subtitleLabel.text = subtitle

        chipsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chips.forEach { chipsStackView.addArrangedSubview(makeChipView($0)) }
        chipsScrollView.isHidden = chips.isEmpty
    }

    private func makeChipView(_ chip: Chip) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: chip.icon))
        iconImageView.tintColor = .wraithPrimary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = chip.text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 13),
            iconImageView.heightAnchor.constraint(equalToConstant: 13)
        ])

        return stack
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius16
        layer.borderWidth = WraithBorderWidth.hairline
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor

        iconContainerView.addSubview(iconImageView)
        chipsScrollView.addSubview(chipsStackView)
        [titleLabel, subtitleLabel].forEach { textStack.addArrangedSubview($0) }
        [iconContainerView, textStack, chevronImageView, chipsScrollView].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            iconContainerView.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space16),
            iconContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            textStack.topAnchor.constraint(equalTo: iconContainerView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: WraithSpacing.space12),

            chevronImageView.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: WraithSpacing.space8),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16),
            chevronImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            chipsScrollView.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: WraithSpacing.space12),
            chipsScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            chipsScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16),
            chipsScrollView.heightAnchor.constraint(equalToConstant: 16),
            chipsScrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WraithSpacing.space16),

            chipsStackView.topAnchor.constraint(equalTo: chipsScrollView.topAnchor),
            chipsStackView.bottomAnchor.constraint(equalTo: chipsScrollView.bottomAnchor),
            chipsStackView.leadingAnchor.constraint(equalTo: chipsScrollView.leadingAnchor),
            chipsStackView.trailingAnchor.constraint(equalTo: chipsScrollView.trailingAnchor),
            chipsStackView.heightAnchor.constraint(equalTo: chipsScrollView.heightAnchor)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1.0 }
    }
}

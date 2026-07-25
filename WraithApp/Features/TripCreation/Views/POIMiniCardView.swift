//
//  POIMiniCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class POIMiniCardView: UIView {

    // MARK: - UI Components

    /// Holds the rounded-corner clip and the fill color — kept separate from `self` so
    /// `self` can host a shadow (shadows and `clipsToBounds` can't coexist on one layer).
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = WraithRadius.radius16
        view.clipsToBounds = true
        view.layer.borderColor = TripAccentTheme.accent.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .wraithSurfaceVariant
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var selectionBadgeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .wraithOnPrimary
        imageView.backgroundColor = TripAccentTheme.accent
        imageView.layer.cornerRadius = WraithRadius.radius11
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.isHidden = true
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var ratingIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .wraithSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingIconImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingStackView, priceLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// Plain wrapper (not a stack view) so `textStackView` can be inset from the sides
    /// with its own constraints without fighting the arranged-subview width constraints
    /// `mainStackView` would otherwise impose on it directly.
    private lazy var textContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [photoImageView, textContainerView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onTap: (() -> Void)?
    private var isCurrentlySelected = false
    private var baseBackgroundColor: UIColor = .wraithSurface {
        didSet {
            guard !isCurrentlySelected else { return }
            containerView.backgroundColor = baseBackgroundColor
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupLayout()
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .clear
        applyCardShadow()
        containerView.backgroundColor = baseBackgroundColor
    }

    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        textContainerView.addSubview(textStackView)
        photoImageView.addSubview(selectionBadgeImageView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // The photo bleeds edge-to-edge with the card (no inset) so it reads as a
            // proper full-bleed thumbnail; only the text below gets horizontal padding.
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -WraithSpacing.space10),

            photoImageView.heightAnchor.constraint(equalToConstant: WraithSpacing.space140),

            textStackView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: WraithSpacing.space10),
            textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -WraithSpacing.space10),

            ratingIconImageView.widthAnchor.constraint(equalToConstant: 12),
            ratingIconImageView.heightAnchor.constraint(equalToConstant: 12),

            selectionBadgeImageView.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: WraithSpacing.space8),
            selectionBadgeImageView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -WraithSpacing.space8),
            selectionBadgeImageView.widthAnchor.constraint(equalToConstant: 22),
            selectionBadgeImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    // MARK: - Public

    /// Lets a consumer match this card's fill to whichever background tier it's actually
    /// sitting on (a card nested in another card vs. a card sitting directly on the page).
    func setCardBackground(_ color: UIColor) {
        baseBackgroundColor = color
    }

    func configure(with item: POIDisplayItem) {
        nameLabel.text = item.name
        ratingLabel.text = String(format: "%.1f", item.rating)
        priceLabel.text = item.priceText
        priceLabel.isHidden = item.priceText == nil
        photoImageView.setImage(from: item.imageURL)

        let didChange = isCurrentlySelected != item.isSelected
        isCurrentlySelected = item.isSelected
        setSelected(item.isSelected, animated: didChange)
    }

    // MARK: - Selection

    private func setSelected(_ selected: Bool, animated: Bool) {
        guard animated else {
            selectionBadgeImageView.isHidden = !selected
            selectionBadgeImageView.alpha = selected ? 1 : 0
            selectionBadgeImageView.transform = .identity
            containerView.layer.borderWidth = selected ? WraithBorderWidth.selected : 0
            containerView.backgroundColor = selected ? TripAccentTheme.accentSoftBackground : baseBackgroundColor
            return
        }

        // Keep the badge in the view hierarchy for the whole animation and only hide it
        // once we're certain (via `isCurrentlySelected`, checked in the completion) that
        // no newer tap has since flipped the state back — tapping the same card rapidly
        // used to leave two overlapping animations racing, which is why the checkmark
        // would sometimes vanish even though the card was still selected.
        selectionBadgeImageView.isHidden = false

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.containerView.layer.borderWidth = selected ? 2 : 0
            self.containerView.backgroundColor = selected ? TripAccentTheme.accentSoftBackground : self.baseBackgroundColor
            self.selectionBadgeImageView.alpha = selected ? 1 : 0
            self.selectionBadgeImageView.transform = selected ? .identity : CGAffineTransform(scaleX: 0.4, y: 0.4)
        } completion: { _ in
            self.selectionBadgeImageView.isHidden = !self.isCurrentlySelected
        }
    }

    // MARK: - Actions

    @objc private func handleTap() {
        onTap?()
    }
}

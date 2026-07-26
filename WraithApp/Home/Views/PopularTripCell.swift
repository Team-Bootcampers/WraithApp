//
//  PopularTripCell.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class PopularTripCell: UITableViewCell {

    static let reuseIdentifier = "PopularTripCell"

    // MARK: - UI Components

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .wraithSurfaceVariant
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var gradientOverlayView: BottomShadowGradientView = {
        let view = BottomShadowGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Hosts the drop shadow — kept separate from `cardContainerView` since a shadow and
    /// `clipsToBounds` can't coexist on the same layer.
    private lazy var cardShadowContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.applyCardShadow()
        return view
    }()

    /// The full card shell (photo + description + price) sits on this — gives the row a
    /// visible surface of its own instead of its text/price floating directly on the page
    /// background with only the photo above it looking "card-like".
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurface
        view.layer.cornerRadius = WraithRadius.radius24
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var favoriteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "heart")
        configuration.baseForegroundColor = .wraithOnPrimary
        let button = UIButton(configuration: configuration)
        button.backgroundColor = .wraithPhotoScrimLight
        button.layer.cornerRadius = WraithRadius.radius18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var ratingIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .wraithSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .wraithOnPrimary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.wraithOnPrimary.withAlphaComponent(0.8)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var durationIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock.fill"))
        imageView.tintColor = UIColor.wraithOnPrimary.withAlphaComponent(0.8)
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.wraithOnPrimary.withAlphaComponent(0.8)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// A trailing flexible spacer absorbs any leftover width so the rating icon, score,
    /// review count and duration stay tightly packed together on the leading edge instead
    /// of the stack view spreading them apart when it's stretched to the card's full width.
    private lazy var ratingTrailingSpacerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            ratingIconImageView, ratingLabel, reviewCountLabel,
            durationIconImageView, durationLabel,
            ratingTrailingSpacerView
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space4
        stack.setCustomSpacing(WraithSpacing.space12, after: reviewCountLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var overlayTextStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, ratingStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Purely decorative — the whole cell is already tappable and leads to the detail
    /// screen, this just visually hints at that on every card.
    private lazy var detailChevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right.circle.fill"))
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var descriptionRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, detailChevronImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .wraithPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [descriptionRowStackView, priceLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// Plain wrapper (not a stack view) so `textStackView` can be inset from the sides with
    /// its own constraints without fighting the arranged-subview width constraints
    /// `contentStackView` would otherwise impose on it directly.
    private lazy var textContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageContainerView, textContainerView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onFavoriteTap: (() -> Void)?

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
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
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardShadowContainerView)
        cardShadowContainerView.addSubview(cardContainerView)
        cardContainerView.addSubview(contentStackView)
        textContainerView.addSubview(textStackView)
        imageContainerView.addSubview(photoImageView)
        imageContainerView.addSubview(gradientOverlayView)
        imageContainerView.addSubview(favoriteButton)
        imageContainerView.addSubview(overlayTextStackView)

        NSLayoutConstraint.activate([
            // The card is 90% of the screen's width, centered, rather than running
            // edge-to-edge like a default table row.
            cardShadowContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space12),
            cardShadowContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space12),
            cardShadowContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardShadowContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),

            cardContainerView.topAnchor.constraint(equalTo: cardShadowContainerView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: cardShadowContainerView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: cardShadowContainerView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: cardShadowContainerView.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -WraithSpacing.space16),

            textStackView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: WraithSpacing.space16),
            textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -WraithSpacing.space16),

            imageContainerView.heightAnchor.constraint(equalToConstant: WraithSpacing.space220),

            photoImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            gradientOverlayView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            gradientOverlayView.heightAnchor.constraint(equalTo: imageContainerView.heightAnchor, multiplier: 0.65),

            favoriteButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: WraithSpacing.space12),
            favoriteButton.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -WraithSpacing.space12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 36),
            favoriteButton.heightAnchor.constraint(equalToConstant: 36),

            overlayTextStackView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: WraithSpacing.space16),
            overlayTextStackView.trailingAnchor.constraint(lessThanOrEqualTo: imageContainerView.trailingAnchor, constant: -WraithSpacing.space16),
            overlayTextStackView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -WraithSpacing.space16),

            ratingIconImageView.widthAnchor.constraint(equalToConstant: 14),
            ratingIconImageView.heightAnchor.constraint(equalToConstant: 14),

            durationIconImageView.widthAnchor.constraint(equalToConstant: 14),
            durationIconImageView.heightAnchor.constraint(equalToConstant: 14),

            detailChevronImageView.widthAnchor.constraint(equalToConstant: 44),
            detailChevronImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        // An explicit shadow path lets Core Animation skip re-rasterizing the shadow's alpha
        // mask on every frame — without it, the press-down animation below would be janky.
        cardShadowContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: cardShadowContainerView.bounds,
            cornerRadius: cardContainerView.layer.cornerRadius
        ).cgPath
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // `selectionStyle = .none` leaves taps with zero visual feedback by default — a
        // subtle press-down on the card itself keeps every row feeling responsive.
        let transform: CGAffineTransform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.cardShadowContainerView.transform = transform
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.setImage(from: nil)
        titleLabel.text = nil
        ratingLabel.text = nil
        reviewCountLabel.text = nil
        durationLabel.text = nil
        descriptionLabel.text = nil
        priceLabel.text = nil
        onFavoriteTap = nil
        setFavorite(false)
    }

    // MARK: - Public

    func configure(with trip: PopularTrip) {
        photoImageView.setImage(from: trip.imageURL)
        titleLabel.text = trip.title
        ratingLabel.text = String(format: "%.1f", trip.rating)
        reviewCountLabel.text = "(\(trip.reviewCount))"
        durationLabel.text = trip.durationText
        descriptionLabel.text = trip.description
        priceLabel.text = formattedPrice(trip.price, currency: trip.currency)
        setFavorite(trip.isFavorite)
    }

    // MARK: - Public

    func setFavorite(_ isFavorite: Bool) {
        // Reused cells must not inherit an in-flight symbol cross-fade from whatever trip
        // the cell last displayed, so state changes on reuse/configure apply instantly.
        UIView.performWithoutAnimation {
            favoriteButton.configuration?.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
            favoriteButton.configuration?.baseForegroundColor = isFavorite ? .wraithPrimary : .wraithOnPrimary
            favoriteButton.layoutIfNeeded()
        }
    }

    // MARK: - Private

    private func formattedPrice(_ price: Int, currency: String) -> String {
        let formatted = Self.priceFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return "\(formatted) \(currency)"
    }

    // MARK: - Actions

    @objc private func didTapFavorite() {
        onFavoriteTap?()
    }
}

// MARK: - BottomShadowGradientView

/// Darkens the bottom of the photo so the white title/rating text stays legible regardless
/// of what's in the underlying image.
private final class BottomShadowGradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.wraithPhotoScrimHeavy.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

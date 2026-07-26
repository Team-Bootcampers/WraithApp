//
//  POIMiniCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class POIMiniCardView: UIView, UIGestureRecognizerDelegate {

    // MARK: - UI Components

    /// Holds the rounded-corner clip and the fill color — kept separate from `self` so
    /// `self` can host a shadow (shadows and `clipsToBounds` can't coexist on one layer).
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = WraithRadius.radius16
        view.clipsToBounds = true
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

    /// A plain white halo sitting behind the checkmark glyph — matches the standard iOS
    /// photo-picker selection treatment (a light backing so the mark stays legible against
    /// any photo) instead of a flat colored square badge.
    private lazy var selectionBadgeHaloView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 3
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.isHidden = true
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var selectionBadgeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .wraithSelection
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
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
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = TripAccentTheme.accent
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Opt-in caption shown under the price for an already-purchased hotel (see
    /// `POIDisplayItem.confirmationText`) — hidden for every other use of this card.
    private lazy var confirmationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemGreen
        label.numberOfLines = 1
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Hidden by default — only a caller that opts in (currently: the hotel recap in Trip
    /// Summary) shows this, via `setActionButton(title:)`. Every other place this card is
    /// used (Trip Creation's selection carousels, the grid, other recap rows) leaves it out.
    private lazy var actionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: WraithSpacing.space8, leading: WraithSpacing.space12, bottom: WraithSpacing.space8, trailing: WraithSpacing.space12)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
        button.applyStandardPressAnimation()
        return button
    }()

    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingStackView, priceLabel, confirmationLabel, actionButton])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space6
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(WraithSpacing.space8, after: priceLabel)
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
        stack.spacing = WraithSpacing.space6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onTap: (() -> Void)?
    var onActionTap: (() -> Void)?
    private var isCurrentlySelected = false
    /// True while the current item carries `confirmationText` — swaps the selection border
    /// from the normal accent color to green, since this card represents a completed
    /// purchase rather than an in-progress pick.
    private var isConfirmed = false
    private let photoHeight: CGFloat
    private var baseBackgroundColor: UIColor = .wraithSurface {
        didSet {
            guard !isCurrentlySelected else { return }
            containerView.backgroundColor = baseBackgroundColor
        }
    }

    // MARK: - Init

    /// - Parameter photoHeight: lets a consumer scale the thumbnail up for a "showcase" style
    ///   carousel (e.g. hotel/place/restaurant selection) vs. the compact default used in
    ///   grids and recap rows.
    init(photoHeight: CGFloat = WraithSpacing.space140) {
        self.photoHeight = photoHeight
        super.init(frame: .zero)
        setupAppearance()
        setupLayout()
        isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .clear
        // A much lighter, tighter shadow than the shared `applyCardShadow()` default — these
        // cards sit packed close together (12-18pt gaps), so both the shared blur radius and
        // its opacity spilled past each card's edge far enough to overlap its neighbor's,
        // making the gaps between cards read as a continuous gray wash instead of individual
        // cards with their own subtle lift.
        layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.masksToBounds = false
        containerView.backgroundColor = baseBackgroundColor
        // A permanent hairline border keeps the card legible against the page background on
        // its own, instead of depending entirely on the shadow for definition.
        containerView.layer.borderWidth = WraithBorderWidth.hairline
        containerView.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        textContainerView.addSubview(textStackView)
        photoImageView.addSubview(selectionBadgeHaloView)
        selectionBadgeHaloView.addSubview(selectionBadgeImageView)
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
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -WraithSpacing.space8),

            photoImageView.heightAnchor.constraint(equalToConstant: photoHeight),

            textStackView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: WraithSpacing.space10),
            textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -WraithSpacing.space10),

            ratingIconImageView.widthAnchor.constraint(equalToConstant: 12),
            ratingIconImageView.heightAnchor.constraint(equalToConstant: 12),

            selectionBadgeHaloView.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: WraithSpacing.space8),
            selectionBadgeHaloView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -WraithSpacing.space8),
            selectionBadgeHaloView.widthAnchor.constraint(equalToConstant: 28),
            selectionBadgeHaloView.heightAnchor.constraint(equalToConstant: 28),

            selectionBadgeImageView.centerXAnchor.constraint(equalTo: selectionBadgeHaloView.centerXAnchor),
            selectionBadgeImageView.centerYAnchor.constraint(equalTo: selectionBadgeHaloView.centerYAnchor),
            selectionBadgeImageView.widthAnchor.constraint(equalToConstant: 24),
            selectionBadgeImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard !isCurrentlySelected else { return }
        containerView.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    // MARK: - Public

    /// Lets a consumer match this card's fill to whichever background tier it's actually
    /// sitting on (a card nested in another card vs. a card sitting directly on the page).
    func setCardBackground(_ color: UIColor) {
        baseBackgroundColor = color
    }

    /// Shows (or hides, if `title` is `nil`) a small CTA below the price — opt-in per
    /// consumer since most places this card appears (selection carousels, the grid) don't
    /// want one.
    func setActionButton(title: String?) {
        guard let title else {
            actionButton.isHidden = true
            return
        }
        actionButton.configuration?.title = title
        actionButton.isHidden = false
    }

    func configure(with item: POIDisplayItem) {
        nameLabel.text = item.name
        ratingLabel.text = String(format: "%.1f", item.rating)
        priceLabel.text = item.priceText
        priceLabel.isHidden = item.priceText == nil
        photoImageView.setImage(from: item.imageURL)
        confirmationLabel.text = item.confirmationText
        confirmationLabel.isHidden = item.confirmationText == nil

        let didChange = isCurrentlySelected != item.isSelected
        isCurrentlySelected = item.isSelected
        isConfirmed = item.confirmationText != nil
        selectionBadgeImageView.tintColor = isConfirmed ? .systemGreen : .wraithSelection
        setSelected(item.isSelected, animated: didChange)
    }

    // MARK: - Selection

    private func setSelected(_ selected: Bool, animated: Bool) {
        let selectionColor: UIColor = isConfirmed ? .systemGreen : .wraithSelection
        let selectionBackground: UIColor = isConfirmed ? UIColor.systemGreen.withAlphaComponent(0.12) : TripAccentTheme.selectionSoftBackground

        guard animated else {
            selectionBadgeHaloView.isHidden = !selected
            selectionBadgeHaloView.alpha = selected ? 1 : 0
            selectionBadgeHaloView.transform = .identity
            containerView.layer.borderWidth = selected ? WraithBorderWidth.selected : WraithBorderWidth.hairline
            containerView.layer.borderColor = (selected ? selectionColor : .wraithOutlineVariant).cgColor
            containerView.backgroundColor = selected ? selectionBackground : baseBackgroundColor
            return
        }

        // Keep the badge in the view hierarchy for the whole animation and only hide it
        // once we're certain (via `isCurrentlySelected`, checked in the completion) that
        // no newer tap has since flipped the state back — tapping the same card rapidly
        // used to leave two overlapping animations racing, which is why the checkmark
        // would sometimes vanish even though the card was still selected.
        selectionBadgeHaloView.isHidden = false

        // A quick squash-and-settle on the whole card, on top of the border/badge
        // transition below, makes toggling a selection feel like a deliberate action
        // instead of a static color swap.
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
                self.containerView.transform = .identity
            }
        }

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.containerView.layer.borderWidth = selected ? WraithBorderWidth.selected : WraithBorderWidth.hairline
            self.containerView.layer.borderColor = (selected ? selectionColor : .wraithOutlineVariant).cgColor
            self.containerView.backgroundColor = selected ? selectionBackground : self.baseBackgroundColor
            self.selectionBadgeHaloView.alpha = selected ? 1 : 0
            self.selectionBadgeHaloView.transform = selected ? .identity : CGAffineTransform(scaleX: 0.4, y: 0.4)
        } completion: { _ in
            self.selectionBadgeHaloView.isHidden = !self.isCurrentlySelected
        }
    }

    // MARK: - Actions

    @objc private func handleTap() {
        onTap?()
    }

    @objc private func handleActionButtonTap() {
        onActionTap?()
    }

    // MARK: - UIGestureRecognizerDelegate

    /// Without this, tapping `actionButton` also fired the card's own tap gesture (toggling
    /// selection) underneath it — the button's own `touchUpInside` doesn't stop a sibling
    /// gesture recognizer from seeing the same touch.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !actionButton.isHidden && touch.view?.isDescendant(of: actionButton) == true ? false : true
    }
}

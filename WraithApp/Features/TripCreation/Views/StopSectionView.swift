//
//  StopSectionView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class StopSectionView: BaseCardView {

    // MARK: - Properties

    private let chevronButton: UIButton
    private let deleteButton: UIButton
    private var collapsedHeightConstraint: NSLayoutConstraint!
    private(set) var isExpanded = true

    var onDelete: (() -> Void)?

    private lazy var innerCardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    init(stopNumber: Int, cardViews: [UIView]) {
        let chevronButton = UIButton(type: .system)
        var chevronConfiguration = UIButton.Configuration.plain()
        chevronConfiguration.image = UIImage(systemName: "chevron.up")
        chevronConfiguration.baseForegroundColor = AppTheme.accent
        chevronConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        chevronButton.configuration = chevronConfiguration
        self.chevronButton = chevronButton

        let deleteButton = UIButton(type: .system)
        var deleteConfiguration = UIButton.Configuration.plain()
        deleteConfiguration.image = UIImage(systemName: "trash")
        deleteConfiguration.baseForegroundColor = .systemRed
        deleteConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        deleteButton.configuration = deleteConfiguration
        deleteButton.isHidden = true
        self.deleteButton = deleteButton

        let accessoryStackView = UIStackView(arrangedSubviews: [deleteButton, chevronButton])
        accessoryStackView.axis = .horizontal
        accessoryStackView.spacing = 2

        super.init(title: "\(stopNumber). Durak", accessoryView: accessoryStackView)

        // Recede behind the nested cards instead of sharing their background tier —
        // otherwise a secondary-tier card sits directly on a secondary-tier card and the
        // two are indistinguishable except for the shadow line between them.
        configureContainer(backgroundColor: .systemGroupedBackground, borderColor: .separator)

        chevronButton.addTarget(self, action: #selector(didTapChevron), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)

        cardViews.forEach { innerCardsStackView.addArrangedSubview($0) }
        contentContainerView.addSubview(innerCardsStackView)

        // Collapsing is driven purely by animating this height to 0 (plus a fade), never
        // by toggling `isHidden` — `isHidden` snaps the view's visibility instantly, which
        // is what produced the "content vanishes, *then* the gap closes a beat later" flash.
        // Clipping the container and forcing its height to 0 lets the content shrink away
        // continuously instead, with nothing popping in or out abruptly.
        contentContainerView.clipsToBounds = true
        collapsedHeightConstraint = contentContainerView.heightAnchor.constraint(equalToConstant: 0)
        collapsedHeightConstraint.isActive = false

        let innerCardsBottomConstraint = innerCardsStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        // Below `.required` so it can yield (instead of logging a conflict) when the
        // collapsed height constraint is active and forces the container to 0pt.
        innerCardsBottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            innerCardsStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            // Bleed slightly past the standard card padding so the nested cards aren't
            // squeezed by two layers of inset (this section's own padding plus each
            // nested card's own padding).
            innerCardsStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: -8),
            innerCardsStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: 8),
            innerCardsBottomConstraint
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded

        let updates = {
            self.collapsedHeightConstraint.isActive = !expanded
            self.contentContainerView.alpha = expanded ? 1 : 0
            self.chevronButton.transform = expanded ? .identity : CGAffineTransform(rotationAngle: .pi - 0.0001)
        }

        guard animated else {
            updates()
            return
        }

        let animationContainer = nearestScrollViewOrSelf

        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            updates()
            animationContainer.layoutIfNeeded()
        }
    }

    func setDeletable(_ deletable: Bool) {
        deleteButton.isHidden = !deletable
    }

    func updateStopNumber(_ number: Int) {
        updateTitle("\(number). Durak")
    }

    // MARK: - Actions

    @objc private func didTapChevron() {
        setExpanded(!isExpanded, animated: true)
    }

    @objc private func didTapDelete() {
        onDelete?()
    }
}

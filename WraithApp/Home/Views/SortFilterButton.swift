//
//  SortFilterButton.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class SortFilterButton: UIButton {

    // MARK: - Properties

    let option: PopularTripSortOption

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    init(option: PopularTripSortOption) {
        self.option = option
        super.init(frame: .zero)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = option.title
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: WraithSpacing.space10,
            leading: WraithSpacing.space16,
            bottom: WraithSpacing.space10,
            trailing: WraithSpacing.space16
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        self.configuration = configuration

        layer.cornerRadius = WraithRadius.radius18
        layer.borderWidth = WraithBorderWidth.hairline
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
        applyStandardPressAnimation()
        updateAppearance()
    }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }

    // MARK: - Private

    private func updateAppearance() {
        // Sits on the page background, not another card, so it needs its own fill + hairline
        // border to read as a chip — matching `wraithSurfaceVariant` (the neutral "inactive"
        // token) would make it blend straight into the page like it used to.
        backgroundColor = isSelected ? .wraithPrimary : .wraithSurface
        layer.borderColor = (isSelected ? UIColor.wraithPrimary : .wraithOutlineVariant).cgColor
        configuration?.baseForegroundColor = isSelected ? .wraithOnPrimary : .wraithOnSurfaceVariant
    }
}

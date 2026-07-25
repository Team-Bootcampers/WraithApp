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
            top: WraithSpacing.space8,
            leading: WraithSpacing.space12,
            bottom: WraithSpacing.space8,
            trailing: WraithSpacing.space12
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        self.configuration = configuration

        layer.cornerRadius = WraithRadius.radius18
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
        updateAppearance()
    }

    // MARK: - Private

    private func updateAppearance() {
        backgroundColor = isSelected ? .wraithPrimary : .wraithSurfaceVariant
        configuration?.baseForegroundColor = isSelected ? .wraithOnPrimary : .wraithOnSurfaceVariant
    }
}

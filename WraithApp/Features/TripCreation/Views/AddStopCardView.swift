//
//  AddStopCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class AddStopCardView: UIView {

    // MARK: - UI Components

    private lazy var addButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Durak Ekleyin"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePlacement = .leading
        configuration.imagePadding = WraithSpacing.space8
        configuration.baseForegroundColor = TripAccentTheme.accent
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return button
    }()

    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = TripAccentTheme.accent.withAlphaComponent(0.4).cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineDashPattern = [6, 4]
        layer.lineWidth = WraithBorderWidth.emphasized
        return layer
    }()

    // MARK: - Properties

    var onTap: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius16
        layer.addSublayer(borderLayer)
    }

    private func setupLayout() {
        addSubview(addButton)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: WraithSpacing.space60),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        onTap?()
    }
}

//
//  ShareCodeCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Shows the traveler's own persona code with copy / share affordances.
final class ShareCodeCardView: BaseCardView {

    // MARK: - UI Components

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var codeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var copyButton = makeActionButton(title: "Kopyala", iconSystemName: "doc.on.doc", action: #selector(didTapCopy))

    private lazy var shareButton = makeActionButton(title: "Paylaş", iconSystemName: "square.and.arrow.up", action: #selector(didTapShare))

    private lazy var actionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [copyButton, shareButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [codeContainerView, actionsStackView])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onCopy: (() -> Void)?
    var onShare: (() -> Void)?

    // MARK: - Init

    init() {
        super.init(title: "Senin Kodun", iconSystemName: "qrcode")
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupLayout() {
        codeContainerView.addSubview(codeLabel)
        contentContainerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            codeLabel.topAnchor.constraint(equalTo: codeContainerView.topAnchor, constant: WraithSpacing.space12),
            codeLabel.leadingAnchor.constraint(equalTo: codeContainerView.leadingAnchor, constant: WraithSpacing.space12),
            codeLabel.trailingAnchor.constraint(equalTo: codeContainerView.trailingAnchor, constant: -WraithSpacing.space12),
            codeLabel.bottomAnchor.constraint(equalTo: codeContainerView.bottomAnchor, constant: -WraithSpacing.space12)
        ])
    }

    private func makeActionButton(title: String, iconSystemName: String, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: iconSystemName)
        configuration.imagePadding = WraithSpacing.space8
        configuration.baseForegroundColor = .wraithPrimary
        configuration.background.strokeColor = .wraithPrimary
        configuration.background.strokeWidth = WraithBorderWidth.hairline
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: WraithSpacing.space12,
            leading: WraithSpacing.space16,
            bottom: WraithSpacing.space12,
            trailing: WraithSpacing.space16
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Binding

    func configure(code: String) {
        codeLabel.text = code
    }

    func showCopiedFeedback() {
        copyButton.configuration?.title = "Kopyalandı"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyButton.configuration?.title = "Kopyala"
        }
    }

    // MARK: - Actions

    @objc private func didTapCopy() {
        onCopy?()
    }

    @objc private func didTapShare() {
        onShare?()
    }
}

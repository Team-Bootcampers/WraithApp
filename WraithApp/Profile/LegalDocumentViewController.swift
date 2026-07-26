//
//  LegalDocumentViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Scrollable detail screen used for both the Privacy Policy and Terms of Use.
final class LegalDocumentViewController: UIViewController {

    private let document: LegalDocument

    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        return label
    }()

    private let introLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let sectionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space24
        return stack
    }()

    init(document: LegalDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = document.title
        lastUpdatedLabel.text = document.lastUpdated
        introLabel.text = document.intro
        setupSections()
        setupLayout()
    }

    private func setupSections() {
        for section in document.sections {
            let headingLabel = UILabel()
            headingLabel.translatesAutoresizingMaskIntoConstraints = false
            headingLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            headingLabel.textColor = .wraithOnSurface
            headingLabel.numberOfLines = 0
            headingLabel.text = section.heading

            let bodyLabel = UILabel()
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
            bodyLabel.textColor = .wraithOnSurfaceVariant
            bodyLabel.numberOfLines = 0
            bodyLabel.text = section.body

            let sectionStack = UIStackView(arrangedSubviews: [headingLabel, bodyLabel])
            sectionStack.translatesAutoresizingMaskIntoConstraints = false
            sectionStack.axis = .vertical
            sectionStack.spacing = WraithSpacing.space8

            sectionsStackView.addArrangedSubview(sectionStack)
        }
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(lastUpdatedLabel)
        contentView.addSubview(introLabel)
        contentView.addSubview(sectionsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            lastUpdatedLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space16),
            lastUpdatedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            lastUpdatedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            introLabel.topAnchor.constraint(equalTo: lastUpdatedLabel.bottomAnchor, constant: WraithSpacing.space12),
            introLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            introLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            sectionsStackView.topAnchor.constraint(equalTo: introLabel.bottomAnchor, constant: WraithSpacing.space32),
            sectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            sectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            sectionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space40)
        ])
    }
}

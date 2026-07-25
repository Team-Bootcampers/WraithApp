//
//  TravelIdentityViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class TravelIdentityViewController: UIViewController {

    // MARK: - Callbacks

    var onMakeFirstPlan: (() -> Void)?
    var onEditProfile: (() -> Void)?

    // MARK: - Data

    private let result: TravelIdentityResult

    // MARK: - Subviews

    private let kickerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SEYAHAT KİMLİĞİNİZ HAZIR"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithSecondary
        label.textAlignment = .center
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithSecondary
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let insightCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius16
        view.clipsToBounds = true
        return view
    }()

    private let insightAccentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        return view
    }()

    private let insightTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .wraithOnSurface
        return label
    }()

    private let insightDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let makeFirstPlanButton = GradientCapsuleButton(title: "İlk Planımı Yap")

    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Profili Düzenle"
        config.baseForegroundColor = .wraithPrimary
        config.background.strokeColor = .wraithPrimary
        config.background.strokeWidth = WraithBorderWidth.emphasized
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(
            top: WraithSpacing.space18,
            leading: WraithSpacing.space32,
            bottom: WraithSpacing.space18,
            trailing: WraithSpacing.space32
        )
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var contentGroup: [UIView] {
        [kickerLabel, dividerView, titleLabel, summaryLabel, insightCardView, makeFirstPlanButton, editProfileButton]
    }

    // MARK: - Init

    init(result: TravelIdentityResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        setupContent()
        setupLayout()
        setupActions()
        prepareEntranceState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup

    private func setupContent() {
        titleLabel.text = result.title
        summaryLabel.text = result.summary
        insightTitleLabel.text = result.insightTitle
        insightDescriptionLabel.text = result.insightDescription
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(kickerLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(summaryLabel)

        insightCardView.addSubview(insightAccentView)
        insightCardView.addSubview(insightTitleLabel)
        insightCardView.addSubview(insightDescriptionLabel)
        contentView.addSubview(insightCardView)

        contentView.addSubview(makeFirstPlanButton)
        contentView.addSubview(editProfileButton)

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

            kickerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space40),
            kickerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            dividerView.topAnchor.constraint(equalTo: kickerLabel.bottomAnchor, constant: WraithSpacing.space14),
            dividerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 40),
            dividerView.heightAnchor.constraint(equalToConstant: 2),

            titleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: WraithSpacing.space24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: WraithSpacing.space12),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            insightCardView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: WraithSpacing.space32),
            insightCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            insightCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            insightAccentView.topAnchor.constraint(equalTo: insightCardView.topAnchor),
            insightAccentView.leadingAnchor.constraint(equalTo: insightCardView.leadingAnchor),
            insightAccentView.bottomAnchor.constraint(equalTo: insightCardView.bottomAnchor),
            insightAccentView.widthAnchor.constraint(equalToConstant: 4),

            insightTitleLabel.topAnchor.constraint(equalTo: insightCardView.topAnchor, constant: WraithSpacing.space20),
            insightTitleLabel.leadingAnchor.constraint(equalTo: insightAccentView.trailingAnchor, constant: WraithSpacing.space16),
            insightTitleLabel.trailingAnchor.constraint(equalTo: insightCardView.trailingAnchor, constant: -WraithSpacing.space20),

            insightDescriptionLabel.topAnchor.constraint(equalTo: insightTitleLabel.bottomAnchor, constant: WraithSpacing.space10),
            insightDescriptionLabel.leadingAnchor.constraint(equalTo: insightAccentView.trailingAnchor, constant: WraithSpacing.space16),
            insightDescriptionLabel.trailingAnchor.constraint(equalTo: insightCardView.trailingAnchor, constant: -WraithSpacing.space20),
            insightDescriptionLabel.bottomAnchor.constraint(equalTo: insightCardView.bottomAnchor, constant: -WraithSpacing.space20),

            makeFirstPlanButton.topAnchor.constraint(equalTo: insightCardView.bottomAnchor, constant: WraithSpacing.space32),
            makeFirstPlanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            makeFirstPlanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            editProfileButton.topAnchor.constraint(equalTo: makeFirstPlanButton.bottomAnchor, constant: WraithSpacing.space12),
            editProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            editProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            editProfileButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space32)
        ])
    }

    private func setupActions() {
        makeFirstPlanButton.addTarget(self, action: #selector(didTapMakeFirstPlan), for: .touchUpInside)
        makeFirstPlanButton.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        makeFirstPlanButton.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        editProfileButton.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        editProfileButton.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Animations

    private func prepareEntranceState() {
        for view in contentGroup {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 16)
        }
    }

    private func animateEntrance() {
        for (index, view) in contentGroup.enumerated() {
            UIView.animate(
                withDuration: 0.35,
                delay: 0.045 * Double(index),
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut]
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }

    // MARK: - Actions

    @objc private func didTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }

    @objc private func didTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            sender.transform = .identity
        }
    }

    @objc private func didTapMakeFirstPlan() {
        onMakeFirstPlan?()
    }

    @objc private func didTapEditProfile() {
        onEditProfile?()
    }
}

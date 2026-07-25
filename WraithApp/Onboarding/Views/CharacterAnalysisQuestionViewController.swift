//
//  CharacterAnalysisQuestionViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class CharacterAnalysisQuestionViewController: UIViewController {

    // MARK: - Callbacks

    var onBack: (() -> Void)?
    var onNext: ((QuizOption) -> Void)?
    var onSkip: (() -> Void)?

    // MARK: - Data

    private let question: QuizQuestion
    private let questionIndex: Int
    private let totalQuestions: Int
    private var optionCards: [QuizOptionCardView] = []
    private var selectedOption: QuizOption? {
        didSet { updateNextButtonState(animated: true) }
    }

    // MARK: - Subviews

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Geri"
        config.baseForegroundColor = .wraithPrimary
        config.contentInsets = NSDirectionalEdgeInsets(
            top: WraithSpacing.space8,
            leading: WraithSpacing.space16,
            bottom: WraithSpacing.space8,
            trailing: WraithSpacing.space16
        )
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Geç"
        config.baseForegroundColor = .wraithOnSurfaceVariant
        config.contentInsets = NSDirectionalEdgeInsets(
            top: WraithSpacing.space8,
            leading: WraithSpacing.space16,
            bottom: WraithSpacing.space8,
            trailing: WraithSpacing.space16
        )
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .wraithOutline
        return label
    }()

    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .wraithPrimary
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius3
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        return view
    }()

    private var progressFillWidthConstraint: NSLayoutConstraint?
    private var didAnimateProgress = false

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius38
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        return label
    }()

    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space12
        return stack
    }()

    private let nextButton = GradientCapsuleButton(title: "Sonraki")

    private let initialSelection: QuizOption?

    // MARK: - Init

    init(question: QuizQuestion, questionIndex: Int, totalQuestions: Int, initialSelection: QuizOption? = nil) {
        self.question = question
        self.questionIndex = questionIndex
        self.totalQuestions = totalQuestions
        self.initialSelection = initialSelection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithSurface
        setupContent()
        setupLayout()
        setupActions()
        updateNextButtonState(animated: false)
        prepareEntranceState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didAnimateProgress else { return }
        progressFillWidthConstraint?.isActive = false
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: 0)
        progressFillWidthConstraint?.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup

    private func setupContent() {
        let progress = totalQuestions > 0 ? Int((Double(questionIndex) / Double(totalQuestions)) * 100) : 0
        progressLabel.text = "SORU \(questionIndex) / \(totalQuestions)"
        progressPercentLabel.text = "%\(progress)"
        titleLabel.text = question.title
        iconImageView.image = UIImage(named: question.iconName)

        optionCards = question.options.map { QuizOptionCardView(option: $0) }

        for card in optionCards {
            card.addTarget(self, action: #selector(didTapOption(_:)), for: .touchUpInside)
            card.isSelected = card.option.value == initialSelection?.value
            optionsStackView.addArrangedSubview(card)
        }

        selectedOption = initialSelection
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)
        view.addSubview(skipButton)
        view.addSubview(scrollView)
        view.addSubview(nextButton)
        scrollView.addSubview(contentView)

        contentView.addSubview(progressLabel)
        contentView.addSubview(progressPercentLabel)
        contentView.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(iconContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: WraithSpacing.space4),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space12),

            skipButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space12),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: WraithSpacing.space8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -WraithSpacing.space16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space8),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),

            progressPercentLabel.centerYAnchor.constraint(equalTo: progressLabel.centerYAnchor),
            progressPercentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            progressTrackView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: WraithSpacing.space8),
            progressTrackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            progressTrackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            progressTrackView.heightAnchor.constraint(equalToConstant: 6),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),

            iconContainerView.topAnchor.constraint(equalTo: progressTrackView.bottomAnchor, constant: WraithSpacing.space28),
            iconContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 76),
            iconContainerView.heightAnchor.constraint(equalToConstant: 76),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 38),
            iconImageView.heightAnchor.constraint(equalToConstant: 38),

            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: WraithSpacing.space20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: WraithSpacing.space32),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space24),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space16)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    private func updateNextButtonState(animated: Bool) {
        let isEnabled = selectedOption != nil
        nextButton.isEnabled = isEnabled
        let apply = { self.nextButton.alpha = isEnabled ? 1.0 : 0.4 }
        if animated {
            UIView.animate(withDuration: 0.15, animations: apply)
        } else {
            apply()
        }
    }

    // MARK: - Animations

    private func prepareEntranceState() {
        iconContainerView.alpha = 0
        iconContainerView.transform = CGAffineTransform(translationX: 0, y: 12).scaledBy(x: 0.8, y: 0.8)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 12)
        for (index, card) in optionCards.enumerated() {
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 12 + CGFloat(index) * 4)
        }
    }

    private func animateEntrance() {
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut]
        ) {
            self.iconContainerView.alpha = 1
            self.iconContainerView.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: 0.03, options: [.curveEaseOut]) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        for (index, card) in optionCards.enumerated() {
            UIView.animate(
                withDuration: 0.3,
                delay: 0.04 + 0.03 * Double(index),
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut]
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }

        guard !didAnimateProgress else { return }
        didAnimateProgress = true
        view.layoutIfNeeded()
        progressFillWidthConstraint?.isActive = false
        let progress = totalQuestions > 0 ? CGFloat(questionIndex) / CGFloat(totalQuestions) : 0
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: progress)
        progressFillWidthConstraint?.isActive = true
        UIView.animate(withDuration: 0.35, delay: 0.05, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func didTapOption(_ sender: QuizOptionCardView) {
        optionCards.forEach { card in
            let isMatch = card === sender
            if card.isSelected != isMatch {
                UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                    card.isSelected = isMatch
                }
            }
        }
        UIView.animate(withDuration: 0.08, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
                sender.transform = .identity
            }
        })
        selectedOption = sender.option
    }

    @objc private func didTapBack() {
        onBack?()
    }

    @objc private func didTapSkip() {
        onSkip?()
    }

    @objc private func didTapNext() {
        guard let selectedOption else { return }
        onNext?(selectedOption)
    }
}

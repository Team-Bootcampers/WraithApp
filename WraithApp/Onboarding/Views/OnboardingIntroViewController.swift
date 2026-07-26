//
//  OnboardingIntroViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class OnboardingIntroViewController: UIViewController {

    // MARK: - Callbacks

    var onStart: (() -> Void)?

    // MARK: - Subviews (App Intro Section)

    private let horizonGlowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithSecondary.withAlphaComponent(0.16)
        return view
    }()

    private let tideGlowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.14)
        return view
    }()

    private let appKickerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "VOYA AI"
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

    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Seyahatin Yeni\nYol Arkadaşı"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let appSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Voya, seyahat tarzını analiz ederek sana özel rotalar, konaklamalar ve deneyimler öneren yapay zeka destekli seyahat asistanındır."
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Subviews (Quiz Intro Section)

    private let quizKickerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "KARAKTER ANALİZİ"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithSecondary
        return label
    }()

    private let quizTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10 Soruda Seyahat\nKimliğini Keşfedelim"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .wraithOnSurface
        label.numberOfLines = 0
        return label
    }()

    private let quizSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Birkaç basit soru soracağız. Süreç şöyle işleyecek:"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space24
        return stack
    }()

    private let startButton = GradientCapsuleButton(title: "Sorulara Başla")

    private var contentGroup: [UIView] {
        [
            appKickerLabel, dividerView, appTitleLabel, appSubtitleLabel,
            quizKickerLabel, quizTitleLabel, quizSubtitleLabel, stepsStackView,
            startButton
        ]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        setupBackground()
        setupSteps()
        setupLayout()
        setupActions()
        prepareEntranceState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        horizonGlowView.layer.cornerRadius = horizonGlowView.bounds.height / 2
        tideGlowView.layer.cornerRadius = tideGlowView.bounds.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: - Setup

    private func setupBackground() {
        view.addSubview(tideGlowView)
        view.addSubview(horizonGlowView)

        NSLayoutConstraint.activate([
            tideGlowView.widthAnchor.constraint(equalToConstant: 360),
            tideGlowView.heightAnchor.constraint(equalToConstant: 360),
            tideGlowView.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space60),
            tideGlowView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: WraithSpacing.space140),

            horizonGlowView.widthAnchor.constraint(equalToConstant: 300),
            horizonGlowView.heightAnchor.constraint(equalToConstant: 300),
            horizonGlowView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space40),
            horizonGlowView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -WraithSpacing.space220)
        ])
    }

    private func setupSteps() {
        let steps = [
            StepRowView(
                number: 1,
                title: "Soruları cevapla",
                description: "Seyahat tarzını ve tercihlerini anlamamız için 10 kısa soru soracağız."
            ),
            StepRowView(
                number: 2,
                title: "Yapay zeka analiz etsin",
                description: "Cevaplarını analiz ederek seyahat karakterini ve önceliklerini çıkaracağız."
            ),
            StepRowView(
                number: 3,
                title: "Seyahat kimliğini keşfet",
                description: "Sana özel bir seyahat profili ve kişiselleştirilmiş öneriler hazır olacak."
            )
        ]
        steps.forEach { stepsStackView.addArrangedSubview($0) }
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(startButton)
        scrollView.addSubview(contentView)

        contentView.addSubview(appKickerLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(appTitleLabel)
        contentView.addSubview(appSubtitleLabel)
        contentView.addSubview(quizKickerLabel)
        contentView.addSubview(quizTitleLabel)
        contentView.addSubview(quizSubtitleLabel)
        contentView.addSubview(stepsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -WraithSpacing.space16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            appKickerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space32),
            appKickerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            dividerView.topAnchor.constraint(equalTo: appKickerLabel.bottomAnchor, constant: WraithSpacing.space14),
            dividerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 40),
            dividerView.heightAnchor.constraint(equalToConstant: 2),

            appTitleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: WraithSpacing.space24),
            appTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            appTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            appSubtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: WraithSpacing.space12),
            appSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            appSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            quizKickerLabel.topAnchor.constraint(equalTo: appSubtitleLabel.bottomAnchor, constant: WraithSpacing.space40),
            quizKickerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),

            quizTitleLabel.topAnchor.constraint(equalTo: quizKickerLabel.bottomAnchor, constant: WraithSpacing.space12),
            quizTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            quizTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            quizSubtitleLabel.topAnchor.constraint(equalTo: quizTitleLabel.bottomAnchor, constant: WraithSpacing.space12),
            quizSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            quizSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            stepsStackView.topAnchor.constraint(equalTo: quizSubtitleLabel.bottomAnchor, constant: WraithSpacing.space32),
            stepsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            stepsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            stepsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space24),

            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space16)
        ])
    }

    private func setupActions() {
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        startButton.addTarget(self, action: #selector(didTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Animations

    private func prepareEntranceState() {
        for view in contentGroup {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 16)
        }
        horizonGlowView.alpha = 0
        tideGlowView.alpha = 0
    }

    private func animateEntrance() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseOut]) {
            self.horizonGlowView.alpha = 1
            self.tideGlowView.alpha = 1
        }

        for (index, view) in contentGroup.enumerated() {
            UIView.animate(
                withDuration: 0.35,
                delay: 0.05 * Double(index),
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

    @objc private func didTapStart() {
        onStart?()
    }
}

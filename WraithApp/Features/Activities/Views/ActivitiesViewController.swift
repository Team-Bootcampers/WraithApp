//
//  ActivitiesViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// "Etkinlikler" tab — landing screen for the persona-driven features (Şaşırt Beni, Seyahat
/// Uyumu), moved out of Profile so they get their own dedicated, more prominent home.
final class ActivitiesViewController: UIViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Kişiliğine Özel"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subheaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Karakter analizinden doğan, sürpriz dolu deneyimler."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var surpriseTripCard = ActivityHeroCardView(
        iconSystemName: "wand.and.stars",
        title: "Şaşırt Beni",
        subtitle: "Bütçeni söyle, destinasyonu son ana kadar gizli tutalım."
    )

    private lazy var compatibilityCard = ActivityHeroCardView(
        iconSystemName: "heart.text.square.fill",
        title: "Seyahat Uyumu",
        subtitle: "Arkadaşınla ne kadar uyumlu seyahat ettiğinizi ölç."
    )

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerLabel, subheaderLabel, surpriseTripCard, compatibilityCard])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space20
        stack.setCustomSpacing(WraithSpacing.space4, after: headerLabel)
        stack.setCustomSpacing(WraithSpacing.space32, after: subheaderLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onRequestRetakeOnboarding: (() -> Void)?
    var onTripSaved: ((SavedTrip) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Etkinlikler"
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: WraithSpacing.space24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: WraithSpacing.space24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -WraithSpacing.space24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -WraithSpacing.space32)
        ])
    }

    private func setupActions() {
        surpriseTripCard.addTarget(self, action: #selector(didTapSurpriseTrip), for: .touchUpInside)
        compatibilityCard.addTarget(self, action: #selector(didTapCompatibility), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapSurpriseTrip() {
        guard let persona = requirePersona() else { return }
        let viewController = SurpriseTripViewController(persona: persona)
        viewController.onTripSaved = { [weak self] trip in self?.onTripSaved?(trip) }
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func didTapCompatibility() {
        guard let persona = requirePersona() else { return }
        let viewController = TravelCompatibilityViewController(persona: persona)
        viewController.onTripSaved = { [weak self] trip in self?.onTripSaved?(trip) }
        navigationController?.pushViewController(viewController, animated: true)
    }

    /// Both features are built on the character analysis, so nudge the traveler into it
    /// instead of opening a screen that could only show an empty state.
    private func requirePersona() -> TravelPersona? {
        if let persona = TravelPersonaStore.current {
            return persona
        }

        let alert = UIAlertController(
            title: "Önce seyahat kimliğin gerekiyor",
            message: "Bu özellikler karakter analizi sonucuna göre çalışıyor. Kısa testi tamamlayarak başlayabilirsin.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        alert.addAction(UIAlertAction(title: "Teste Başla", style: .default) { [weak self] _ in
            self?.onRequestRetakeOnboarding?()
        })
        present(alert, animated: true)
        return nil
    }
}

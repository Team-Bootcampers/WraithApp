//
//  SurpriseTripViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// "Sürpriz Beni" — plans a real trip but keeps the destination sealed until the reveal.
final class SurpriseTripViewController: UIViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Bütçeni söyle, gerisini bize bırak. Nereye gittiğini son ana kadar söylemeyeceğiz."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var budgetField = WraithTextField(
        placeholder: "Kişi başı bütçen (TL) — opsiyonel",
        keyboardType: .numberPad
    )

    private lazy var basicsCardView = TripBasicsCardView()

    private lazy var mysteryCardView: MysteryDestinationCardView = {
        let view = MysteryDestinationCardView()
        view.isHidden = true
        return view
    }()

    private lazy var planCardView: ItineraryPlanCardView = {
        let view = ItineraryPlanCardView()
        view.isHidden = true
        return view
    }()

    private lazy var prepareButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Sürprizi Hazırla")
        button.addTarget(self, action: #selector(didTapPrepare), for: .touchUpInside)
        return button
    }()

    private lazy var revealButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Perdeyi Kaldır")
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapReveal), for: .touchUpInside)
        return button
    }()

    private lazy var saveButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Planı Kaydet")
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            hintLabel,
            budgetField,
            basicsCardView,
            prepareButton,
            mysteryCardView,
            revealButton,
            planCardView,
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onTripSaved: ((SavedTrip) -> Void)?

    private let viewModel: SurpriseTripViewModel

    // MARK: - Init

    init(persona: TravelPersona) {
        self.viewModel = SurpriseTripViewModel(persona: persona)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Şaşırt Beni"
        setupLayout()
        setupKeyboardDismissal()
    }

    // MARK: - Setup

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        // Without this the gesture eats taps meant for the buttons stacked below the field.
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: WraithSpacing.space16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: WraithSpacing.space24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -WraithSpacing.space24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -WraithSpacing.space32)
        ])
    }

    // MARK: - Actions

    @objc private func didTapPrepare() {
        view.endEditing(true)
        prepareButton.setLoading(true)
        planCardView.isHidden = true
        saveButton.isHidden = true

        Task { [weak self] in
            guard let self else { return }
            let plan = await self.viewModel.prepareSurprise(
                startDate: self.basicsCardView.startDate,
                travelerCount: self.basicsCardView.travelerCount,
                budgetPerPerson: Int(self.budgetField.text ?? "")
            )
            self.prepareButton.setLoading(false)
            guard let plan else { return }
            self.showMystery(plan)
        }
    }

    @objc private func didTapReveal() {
        guard let plan = viewModel.plan else { return }
        viewModel.reveal()
        planCardView.configure(with: plan)

        UIView.transition(with: contentStackView, duration: 0.5, options: [.transitionFlipFromRight]) {
            self.mysteryCardView.isHidden = true
            self.revealButton.isHidden = true
            self.planCardView.isHidden = false
            self.saveButton.isHidden = false
        }
    }

    @objc private func didTapSave() {
        Task { [weak self] in
            guard let self, let trip = await viewModel.save() else { return }
            onTripSaved?(trip)
        }
    }

    // MARK: - Presentation

    private func showMystery(_ plan: ItineraryPlan) {
        mysteryCardView.configure(with: plan, nights: viewModel.nights)
        prepareButton.setTitle("Yeni Sürpriz Hazırla", for: .normal)

        guard mysteryCardView.isHidden else { return }

        mysteryCardView.alpha = 0
        mysteryCardView.isHidden = false
        revealButton.alpha = 0
        revealButton.isHidden = false

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut]) {
            self.mysteryCardView.alpha = 1
            self.revealButton.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}

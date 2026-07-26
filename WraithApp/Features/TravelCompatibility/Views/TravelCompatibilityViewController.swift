//
//  TravelCompatibilityViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// "Seyahat Uyumu" — compares two personas via a shareable code and plans a joint trip.
final class TravelCompatibilityViewController: UIViewController {

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
        label.text = "Kodunu arkadaşına gönder, onun kodunu buraya yapıştır. Beklentilerinizin ne kadar örtüştüğünü hesaplayalım."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var myCodeCardView = ShareCodeCardView()

    private lazy var friendCodeField = WraithTextField(placeholder: "Arkadaşının kodu")

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithError
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var compareButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Uyumu Hesapla")
        button.addTarget(self, action: #selector(didTapCompare), for: .touchUpInside)
        return button
    }()

    private lazy var resultCardView: CompatibilityResultCardView = {
        let view = CompatibilityResultCardView()
        view.isHidden = true
        return view
    }()

    private lazy var basicsCardView: TripBasicsCardView = {
        let view = TripBasicsCardView()
        view.isHidden = true
        return view
    }()

    private lazy var jointPlanButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Ortak Rota Oluştur")
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapGenerateJointPlan), for: .touchUpInside)
        return button
    }()

    private lazy var planCardView: ItineraryPlanCardView = {
        let view = ItineraryPlanCardView()
        view.isHidden = true
        return view
    }()

    private lazy var saveButton: GradientCapsuleButton = {
        let button = GradientCapsuleButton(title: "Ortak Planı Kaydet")
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            hintLabel,
            myCodeCardView,
            friendCodeField,
            errorLabel,
            compareButton,
            resultCardView,
            basicsCardView,
            jointPlanButton,
            planCardView,
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space16
        stack.setCustomSpacing(WraithSpacing.space8, after: friendCodeField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Properties

    var onTripSaved: ((SavedTrip) -> Void)?

    private let viewModel: TravelCompatibilityViewModel

    // MARK: - Init

    init(persona: TravelPersona) {
        self.viewModel = TravelCompatibilityViewModel(persona: persona)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Seyahat Uyumu"
        setupLayout()
        setupKeyboardDismissal()

        myCodeCardView.configure(code: viewModel.myShareCode)
        myCodeCardView.onCopy = { [weak self] in self?.copyMyCode() }
        myCodeCardView.onShare = { [weak self] in self?.shareMyCode() }
    }

    // MARK: - Setup

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

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        // Without this the gesture eats taps meant for the buttons stacked below the field.
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func didTapCompare() {
        view.endEditing(true)

        switch viewModel.compare(with: friendCodeField.text ?? "") {
        case .failure(let error):
            errorLabel.text = error.errorDescription
            errorLabel.isHidden = false
            hideResult()
        case .success(let result):
            errorLabel.isHidden = true
            showResult(result)
        }
    }

    @objc private func didTapGenerateJointPlan() {
        jointPlanButton.setLoading(true)

        Task { [weak self] in
            guard let self else { return }
            let plan = await self.viewModel.generateJointPlan(
                startDate: self.basicsCardView.startDate,
                travelerCount: self.basicsCardView.travelerCount
            )
            self.jointPlanButton.setLoading(false)
            guard let plan else { return }
            self.showJointPlan(plan)
        }
    }

    @objc private func didTapSave() {
        guard let trip = viewModel.save() else { return }
        onTripSaved?(trip)
    }

    private func copyMyCode() {
        UIPasteboard.general.string = viewModel.myShareCode
        myCodeCardView.showCopiedFeedback()
    }

    private func shareMyCode() {
        let activityViewController = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = myCodeCardView
        present(activityViewController, animated: true)
    }

    // MARK: - Presentation

    private func showResult(_ result: CompatibilityResult) {
        resultCardView.configure(with: result)
        planCardView.isHidden = true
        saveButton.isHidden = true

        let canPlanTogether = result.suggestedDestination != nil
        resultCardView.isHidden = false
        basicsCardView.isHidden = !canPlanTogether
        jointPlanButton.isHidden = !canPlanTogether

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
        }
    }

    private func hideResult() {
        [resultCardView, basicsCardView, jointPlanButton, planCardView, saveButton].forEach { $0.isHidden = true }
    }

    private func showJointPlan(_ plan: ItineraryPlan) {
        planCardView.configure(with: plan)
        planCardView.isHidden = false
        saveButton.isHidden = false

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
        }
    }
}

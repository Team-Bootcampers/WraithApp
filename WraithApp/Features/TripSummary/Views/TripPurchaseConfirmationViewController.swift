//
//  TripPurchaseConfirmationViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Presented from Trip Summary's "Öde ve Tamamla" button — lets the traveler optionally add
/// the 59.90 TL detailed-plan add-on before confirming the (mock) purchase.
final class TripPurchaseConfirmationViewController: UIViewController {

    static let planAddOnPrice: Double = 59.90

    // MARK: - UI Components

    private lazy var iconBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = TripAccentTheme.accentSoftBackground
        view.layer.cornerRadius = WraithRadius.radius38
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        imageView.tintColor = TripAccentTheme.accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ödemeyi Tamamla"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rezervasyonunu tamamlamak üzeresin. Dilersen uçtan uca saatlik gezi planını da ekleyebilirsin."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var planAddOnTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Detaylı Gezi Planı"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var planAddOnSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Saatlik, uçtan uca kişiselleştirilmiş gezi planı — \(Self.formattedPlanAddOnPrice)"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var planAddOnTextStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [planAddOnTitleLabel, planAddOnSubtitleLabel])
        stack.axis = .vertical
        stack.spacing = WraithSpacing.space4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// A "+ Ekle" / "✓ Eklendi" pill instead of a settings-style switch — reads as adding an
    /// optional item to the order (like an extra on a food-delivery checkout) rather than
    /// flipping a preference, which is what this actually is.
    private lazy var addOnActionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: WraithSpacing.space8, leading: WraithSpacing.space14, bottom: WraithSpacing.space8, trailing: WraithSpacing.space14)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapToggleAddOn), for: .touchUpInside)
        button.applyStandardPressAnimation()
        return button
    }()

    private lazy var planAddOnRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [planAddOnTextStackView, addOnActionButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = WraithSpacing.space12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// The whole card is tappable (not just the button) — matches the same "tap the card to
    /// pick it" affordance the hotel/place selection carousels already use elsewhere.
    private lazy var planAddOnCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurface
        view.layer.cornerRadius = WraithRadius.radius16
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToggleAddOn)))
        return view
    }()

    private lazy var totalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ödenecek Tutar"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .wraithPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var totalRowStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [totalTitleLabel, totalAmountLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var confirmButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = TripAccentTheme.accent
        configuration.baseForegroundColor = .wraithOnPrimary
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    private let tripTotal: Int
    private var isPlanAddOnSelected = false
    var onConfirm: ((_ includingPlanAddOn: Bool) -> Void)?

    private static let planAddOnPriceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        return formatter
    }()

    private static var formattedPlanAddOnPrice: String {
        let amount = planAddOnPriceFormatter.string(from: NSNumber(value: planAddOnPrice)) ?? "\(planAddOnPrice)"
        return "\(amount) TL"
    }

    private static let totalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // MARK: - Init

    init(tripTotal: Int) {
        self.tripTotal = tripTotal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Vazgeç", style: .plain, target: self, action: #selector(didTapCancel))
        setupLayout()
        updateAddOnAppearance()
    }

    // MARK: - Setup

    private func setupLayout() {
        iconBadgeView.addSubview(iconImageView)
        headerContainerView.addSubview(iconBadgeView)

        planAddOnCardView.addSubview(planAddOnRowStackView)

        let mainStackView = UIStackView(arrangedSubviews: [
            headerContainerView, titleLabel, subtitleLabel, planAddOnCardView, totalRowStackView, confirmButton
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = WraithSpacing.space20
        mainStackView.setCustomSpacing(WraithSpacing.space12, after: headerContainerView)
        mainStackView.setCustomSpacing(WraithSpacing.space4, after: titleLabel)
        mainStackView.setCustomSpacing(WraithSpacing.space28, after: subtitleLabel)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: WraithSpacing.space24),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),

            iconBadgeView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            iconBadgeView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            iconBadgeView.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            iconBadgeView.widthAnchor.constraint(equalToConstant: 64),
            iconBadgeView.heightAnchor.constraint(equalToConstant: 64),

            iconImageView.centerXAnchor.constraint(equalTo: iconBadgeView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBadgeView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            planAddOnRowStackView.topAnchor.constraint(equalTo: planAddOnCardView.topAnchor, constant: WraithSpacing.space16),
            planAddOnRowStackView.leadingAnchor.constraint(equalTo: planAddOnCardView.leadingAnchor, constant: WraithSpacing.space16),
            planAddOnRowStackView.trailingAnchor.constraint(equalTo: planAddOnCardView.trailingAnchor, constant: -WraithSpacing.space16),
            planAddOnRowStackView.bottomAnchor.constraint(equalTo: planAddOnCardView.bottomAnchor, constant: -WraithSpacing.space16)
        ])
    }

    // MARK: - Actions

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapToggleAddOn() {
        isPlanAddOnSelected.toggle()
        updateAddOnAppearance()
    }

    @objc private func didTapConfirm() {
        onConfirm?(isPlanAddOnSelected)
    }

    // MARK: - Private

    private func updateAddOnAppearance() {
        addOnActionButton.configuration?.title = isPlanAddOnSelected ? "✓ Eklendi" : "+ Ekle"
        addOnActionButton.configuration?.baseBackgroundColor = isPlanAddOnSelected ? .wraithSelection : TripAccentTheme.accent
        addOnActionButton.configuration?.baseForegroundColor = .wraithOnPrimary

        UIView.animate(withDuration: 0.2) {
            self.planAddOnCardView.layer.borderWidth = self.isPlanAddOnSelected ? WraithBorderWidth.selected : WraithBorderWidth.hairline
            self.planAddOnCardView.layer.borderColor = (self.isPlanAddOnSelected ? UIColor.wraithSelection : .wraithOutlineVariant).cgColor
            self.planAddOnCardView.backgroundColor = self.isPlanAddOnSelected ? TripAccentTheme.selectionSoftBackground : .wraithSurface
        }

        updateTotal()
    }

    private func updateTotal() {
        let total = Double(tripTotal) + (isPlanAddOnSelected ? Self.planAddOnPrice : 0)
        let formattedTotal = Self.totalFormatter.string(from: NSNumber(value: total)) ?? "\(total)"
        totalAmountLabel.text = "\(formattedTotal) TL"
        confirmButton.configuration?.title = "\(formattedTotal) TL Öde ve Tamamla"
    }
}

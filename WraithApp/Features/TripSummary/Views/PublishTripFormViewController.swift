//
//  PublishTripFormViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Presented from Trip Summary's "Herkese Aç" button to collect the title and description
/// needed to publish a trip — a friendlier full-screen form in place of a plain two-field
/// `UIAlertController`.
final class PublishTripFormViewController: UIViewController {

    // MARK: - UI Components

    private lazy var iconBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.wraithSecondary.withAlphaComponent(0.15)
        view.layer.cornerRadius = WraithRadius.radius38
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "globe"))
        imageView.tintColor = .wraithSecondary
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
        label.text = "Seyahatini Herkese Aç"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Diğer kullanıcıların keşfedebilmesi için seyahatine bir başlık ve açıklama ekle."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleFieldLabel = Self.fieldLabel(text: "Başlık")
    private lazy var titleField = WraithTextField(placeholder: "Örn. Kapadokya'da Unutulmaz 3 Gün")

    private lazy var descriptionFieldLabel = Self.fieldLabel(text: "Açıklama")

    private lazy var descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Seyahatinle ilgili birkaç cümle yaz..."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .wraithOnSurface
        textView.tintColor = .wraithPrimary
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private lazy var descriptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurface
        view.layer.cornerRadius = WraithRadius.radius12
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var shareButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Paylaş"
        configuration.image = UIImage(systemName: "paperplane.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .wraithSecondary
        configuration.baseForegroundColor = .wraithOnSurface
        configuration.cornerStyle = .large
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties

    var onSubmit: ((String, String) -> Void)?

    // MARK: - Init

    init() {
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
    }

    // MARK: - Setup

    private func setupLayout() {
        iconBadgeView.addSubview(iconImageView)
        headerContainerView.addSubview(iconBadgeView)

        descriptionContainerView.addSubview(descriptionTextView)
        descriptionContainerView.addSubview(descriptionPlaceholderLabel)

        let titleFieldStack = UIStackView(arrangedSubviews: [titleFieldLabel, titleField])
        titleFieldStack.axis = .vertical
        titleFieldStack.spacing = WraithSpacing.space8
        titleFieldStack.translatesAutoresizingMaskIntoConstraints = false

        let descriptionFieldStack = UIStackView(arrangedSubviews: [descriptionFieldLabel, descriptionContainerView])
        descriptionFieldStack.axis = .vertical
        descriptionFieldStack.spacing = WraithSpacing.space8
        descriptionFieldStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [
            headerContainerView, titleLabel, subtitleLabel, titleFieldStack, descriptionFieldStack, shareButton
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = WraithSpacing.space20
        mainStackView.setCustomSpacing(WraithSpacing.space12, after: headerContainerView)
        mainStackView.setCustomSpacing(WraithSpacing.space4, after: titleLabel)
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

            descriptionContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: WraithSpacing.space12),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: WraithSpacing.space16),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -WraithSpacing.space16),
            descriptionTextView.bottomAnchor.constraint(lessThanOrEqualTo: descriptionContainerView.bottomAnchor, constant: -WraithSpacing.space12),

            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor)
        ])
    }

    private static func fieldLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .wraithOnSurfaceVariant
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Actions

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapShare() {
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, !description.isEmpty else {
            shakeInvalidFields(titleIsEmpty: title.isEmpty, descriptionIsEmpty: description.isEmpty)
            return
        }

        onSubmit?(title, description)
    }

    private func shakeInvalidFields(titleIsEmpty: Bool, descriptionIsEmpty: Bool) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)

        if titleIsEmpty {
            titleField.layer.borderColor = UIColor.wraithPrimary.cgColor
        }
        if descriptionIsEmpty {
            descriptionContainerView.layer.borderColor = UIColor.wraithPrimary.cgColor
        }

        UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
            self.titleField.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
            self.descriptionContainerView.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
        })
    }
}

// MARK: - UITextViewDelegate

extension PublishTripFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}

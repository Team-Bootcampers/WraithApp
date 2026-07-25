//
//  LoginViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class LoginViewController: UIViewController {

    var onLogin: ((String, String) async throws -> Void)?
    var onSwitchToSignUp: (() -> Void)?
    var onClose: (() -> Void)?

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .wraithOnSurfaceVariant
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tekrar Hoşgeldin"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .wraithOnSurface
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yolculuğuna devam etmek için giriş yap"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.numberOfLines = 0
        return label
    }()

    private let emailField = WraithTextField(placeholder: "E-posta", keyboardType: .emailAddress)
    private let passwordField = WraithTextField(placeholder: "Şifre", isSecure: true)

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .wraithError
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var loginButton = GradientCapsuleButton(title: "Giriş Yap")

    private let signUpPromptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hesabın yok mu?"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        return label
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Kayıt Ol", for: .normal)
        button.setTitleColor(.wraithPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        view.backgroundColor = .wraithBackground

        let bottomStack = UIStackView(arrangedSubviews: [signUpPromptLabel, signUpButton])
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.axis = .horizontal
        bottomStack.spacing = WraithSpacing.space4
        bottomStack.alignment = .center

        [closeButton, titleLabel, subtitleLabel, emailField, passwordField,
         errorLabel, loginButton, bottomStack].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: WraithSpacing.space16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space20),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: WraithSpacing.space24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: WraithSpacing.space8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: WraithSpacing.space40),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: WraithSpacing.space16),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: WraithSpacing.space12),
            errorLabel.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: WraithSpacing.space24),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),

            bottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space24)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }

    @objc private func didTapClose() {
        onClose?()
    }

    @objc private func didTapLogin() {
        Task { await performLogin() }
    }

    private func performLogin() async {
        guard let onLogin else { return }
        errorLabel.isHidden = true

        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""

        do {
            try CredentialValidator.validateEmail(email)
            try CredentialValidator.validatePassword(password)
        } catch {
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
            return
        }

        loginButton.setLoading(true)
        do {
            try await onLogin(email, password)
        } catch {
            errorLabel.text = error.localizedDescription
            errorLabel.isHidden = false
        }
        loginButton.setLoading(false)
    }

    @objc private func didTapSignUp() {
        onSwitchToSignUp?()
    }
}

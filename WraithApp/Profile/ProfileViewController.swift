//
//  ProfileViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    var onRequestRetakeOnboarding: (() -> Void)?

    private var authCoordinator: AuthCoordinator?

    // MARK: - Easter egg state

    private var easterEggTapCount = 0
    private var isShowingEasterEgg = false

    // MARK: - Scroll Container

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Header

    private let avatarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = WraithRadius.radius28
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .wraithPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .wraithOnSurface
        return label
    }()

    // MARK: - Auth action

    private lazy var authActionButton = GradientCapsuleButton(title: "")

    // MARK: - Preferences

    private let themeRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithSurface
        view.layer.cornerRadius = WraithRadius.radius12
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithOutlineVariant.cgColor
        return view
    }()

    private let themeRowTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Koyu Tema"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .wraithOnSurface
        return label
    }()

    private let themeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .wraithPrimary
        return toggle
    }()

    // MARK: - Legal rows

    private let privacyRow = ProfileMenuRow(title: "Gizlilik Politikası")
    private let termsRow = ProfileMenuRow(title: "Kullanım Koşulları")

    // MARK: - Onboarding

    private let retakeOnboardingButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "Karakter Analizini Yeniden Yap"
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

    // MARK: - Footer

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        return label
    }()

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 72, weight: .heavy)
        label.textColor = .wraithPrimary
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Profil"
        versionLabel.text = Self.appVersionText()
        setupLayout()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    // MARK: - Setup

    private func setupLayout() {
        avatarContainerView.addSubview(avatarImageView)

        let headerStack = UIStackView(arrangedSubviews: [avatarContainerView, nameLabel])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = WraithSpacing.space16
        headerStack.alignment = .center

        themeRowView.addSubview(themeRowTitleLabel)
        themeRowView.addSubview(themeSwitch)

        let legalStack = UIStackView(arrangedSubviews: [privacyRow, termsRow])
        legalStack.translatesAutoresizingMaskIntoConstraints = false
        legalStack.axis = .vertical
        legalStack.spacing = WraithSpacing.space12

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(countdownLabel)

        [headerStack, authActionButton, themeRowView, legalStack, retakeOnboardingButton, versionLabel].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            avatarContainerView.widthAnchor.constraint(equalToConstant: 56),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 56),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 26),
            avatarImageView.heightAnchor.constraint(equalToConstant: 26),

            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WraithSpacing.space24),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            headerStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            authActionButton.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: WraithSpacing.space32),
            authActionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            authActionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            themeRowView.topAnchor.constraint(equalTo: authActionButton.bottomAnchor, constant: WraithSpacing.space32),
            themeRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            themeRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            themeRowTitleLabel.leadingAnchor.constraint(equalTo: themeRowView.leadingAnchor, constant: WraithSpacing.space16),
            themeRowTitleLabel.topAnchor.constraint(equalTo: themeRowView.topAnchor, constant: WraithSpacing.space16),
            themeRowTitleLabel.bottomAnchor.constraint(equalTo: themeRowView.bottomAnchor, constant: -WraithSpacing.space16),

            themeSwitch.centerYAnchor.constraint(equalTo: themeRowTitleLabel.centerYAnchor),
            themeSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: themeRowTitleLabel.trailingAnchor, constant: WraithSpacing.space12),
            themeSwitch.trailingAnchor.constraint(equalTo: themeRowView.trailingAnchor, constant: -WraithSpacing.space16),

            legalStack.topAnchor.constraint(equalTo: themeRowView.bottomAnchor, constant: WraithSpacing.space24),
            legalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            legalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            retakeOnboardingButton.topAnchor.constraint(equalTo: legalStack.bottomAnchor, constant: WraithSpacing.space40),
            retakeOnboardingButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retakeOnboardingButton.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            retakeOnboardingButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),

            versionLabel.topAnchor.constraint(equalTo: retakeOnboardingButton.bottomAnchor, constant: WraithSpacing.space24),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WraithSpacing.space24),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WraithSpacing.space24),
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -WraithSpacing.space32),

            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupActions() {
        authActionButton.addTarget(self, action: #selector(didTapAuthAction), for: .touchUpInside)
        themeSwitch.addTarget(self, action: #selector(didToggleTheme(_:)), for: .valueChanged)
        privacyRow.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        termsRow.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        retakeOnboardingButton.addTarget(self, action: #selector(didTapRetakeOnboarding), for: .touchUpInside)

        versionLabel.isUserInteractionEnabled = true
        versionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapVersionLabel)))
    }

    private func refresh() {
        nameLabel.text = UserSession.shared.displayName
        authActionButton.setTitle(
            UserSession.shared.isLoggedIn ? "Çıkış Yap" : "Giriş Yap / Kayıt Ol",
            for: .normal
        )
        themeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
    }

    // MARK: - Actions

    @objc private func didTapAuthAction() {
        if UserSession.shared.isLoggedIn {
            UserSession.shared.logout()
            refresh()
        } else {
            let coordinator = AuthCoordinator(presentingViewController: self)
            coordinator.onFinished = { [weak self] in
                self?.authCoordinator = nil
                self?.refresh()
            }
            authCoordinator = coordinator
            coordinator.start()
        }
    }

    @objc private func didToggleTheme(_ sender: UISwitch) {
        ThemeManager.shared.setTheme(sender.isOn ? .dark : .light)
    }

    @objc private func didTapPrivacy() {
        navigationController?.pushViewController(LegalDocumentViewController(document: .privacyPolicy), animated: true)
    }

    @objc private func didTapTerms() {
        navigationController?.pushViewController(LegalDocumentViewController(document: .termsOfUse), animated: true)
    }

    @objc private func didTapRetakeOnboarding() {
        onRequestRetakeOnboarding?()
    }

    @objc private func didTapVersionLabel() {
        guard !isShowingEasterEgg else { return }
        easterEggTapCount += 1

        guard easterEggTapCount > 5 else { return }

        let remaining = 11 - easterEggTapCount
        showCountdown(remaining)

        if easterEggTapCount >= 10 {
            easterEggTapCount = 0
            isShowingEasterEgg = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.showThankYouEasterEgg()
            }
        }
    }

    // MARK: - Easter egg

    private func showCountdown(_ value: Int) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideCountdown), object: nil)

        countdownLabel.text = "\(value)"
        countdownLabel.alpha = 1
        countdownLabel.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
            self.countdownLabel.transform = .identity
        }

        perform(#selector(hideCountdown), with: nil, afterDelay: 0.8)
    }

    @objc private func hideCountdown() {
        UIView.animate(withDuration: 0.2) {
            self.countdownLabel.alpha = 0
        }
    }

    private func showThankYouEasterEgg() {
        hideCountdown()

        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .wraithBackground
        overlayView.alpha = 0

        let logoView = VoyaLogoView()
        logoView.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "HER ŞEY İÇİN\nTEŞEKKÜRLER WRAITH"
        messageLabel.font = .systemFont(ofSize: 30, weight: .heavy)
        messageLabel.textColor = .wraithPrimary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let contentStack = UIStackView(arrangedSubviews: [logoView, messageLabel])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = WraithSpacing.space24

        overlayView.addSubview(contentStack)
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoView.widthAnchor.constraint(equalToConstant: 96),
            logoView.heightAnchor.constraint(equalToConstant: 96),

            contentStack.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: overlayView.leadingAnchor, constant: WraithSpacing.space32),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -WraithSpacing.space32)
        ])

        view.layoutIfNeeded()
        addConfetti(to: overlayView)

        contentStack.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut]) {
            overlayView.alpha = 1
        }
        UIView.animate(withDuration: 0.55, delay: 0.05, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.6) {
            contentStack.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            UIView.animate(withDuration: 0.5, animations: {
                overlayView.alpha = 0
            }, completion: { _ in
                overlayView.removeFromSuperview()
                self?.isShowingEasterEgg = false
            })
        }
    }

    private func addConfetti(to container: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: container.bounds.width / 2, y: -12)
        emitter.emitterSize = CGSize(width: container.bounds.width, height: 1)
        emitter.frame = container.bounds

        let colors: [UIColor] = [.wraithPrimary, .wraithSecondary, .wraithOnSurface]
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5
            cell.velocity = 130
            cell.velocityRange = 50
            cell.yAcceleration = 140
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 5
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.35
            cell.scaleRange = 0.2
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            return cell
        }

        container.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            emitter.removeFromSuperlayer()
        }
    }

    // MARK: - Helpers

    private static func appVersionText() -> String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Voya \(version) (\(build))"
    }
}

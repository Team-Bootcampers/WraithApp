//
//  SplashViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Welcome screen shown on cold start: logo entrance + typewriter reveal of the app name,
/// held on screen for a fixed total duration before handing off to onboarding.
final class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let totalDisplayDuration: TimeInterval = 3.0
    private let appName = "Voya"
    private var appearedAt: Date?
    private var typingTimer: Timer?
    private var typedCharacterCount = 0

    private let logoView: VoyaLogoView = {
        let view = VoyaLogoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        return label
    }()

    private let caretView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        return view
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "seyahat kimliğini keşfet"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard appearedAt == nil else { return }
        appearedAt = Date()
        animateLogoIn()
        startCaretBlink()
    }

    // MARK: - Layout

    private func setupLayout() {
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, caretView])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal
        titleStack.spacing = WraithSpacing.space4
        titleStack.alignment = .center

        [logoView, titleStack, taglineLabel].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -WraithSpacing.space60),
            logoView.widthAnchor.constraint(equalToConstant: 96),
            logoView.heightAnchor.constraint(equalToConstant: 96),

            titleStack.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: WraithSpacing.space20),
            titleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            caretView.widthAnchor.constraint(equalToConstant: 3),
            caretView.heightAnchor.constraint(equalToConstant: 34),

            taglineLabel.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: WraithSpacing.space10),
            taglineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: WraithSpacing.space24),
            taglineLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -WraithSpacing.space24),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Animations

    private func animateLogoIn() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.logoView.alpha = 1
            self.logoView.transform = .identity
        } completion: { _ in
            self.startTypewriter()
        }
    }

    private func startTypewriter() {
        typedCharacterCount = 0
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.11, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.typedCharacterCount += 1
            self.titleLabel.text = String(self.appName.prefix(self.typedCharacterCount))

            if self.typedCharacterCount >= self.appName.count {
                timer.invalidate()
                self.typingTimer = nil
                UIView.animate(withDuration: 0.3) {
                    self.taglineLabel.alpha = 1
                }
                self.scheduleFinish()
            }
        }
    }

    private func startCaretBlink() {
        caretView.alpha = 1
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.repeat, .autoreverse],
            animations: {
                self.caretView.alpha = 0
            }
        )
    }

    private func scheduleFinish() {
        let elapsed = appearedAt.map { Date().timeIntervalSince($0) } ?? 0
        let remaining = max(0.4, totalDisplayDuration - elapsed)
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
            self?.caretView.layer.removeAllAnimations()
            self?.onFinish?()
        }
    }

    deinit {
        typingTimer?.invalidate()
    }
}

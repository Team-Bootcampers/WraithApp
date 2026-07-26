//
//  TripPlanGenerationLoadingView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Animated, on-brand loading state shown while `/ai/trip-planning` is generating the
/// detailed PDF — mirrors `AnalyzingViewController`'s dual-ring gradient-core animation, with
/// a message label that cycles through several status phrases instead of one static line.
final class TripPlanGenerationLoadingView: UIView {

    // MARK: - UI Components

    private lazy var outerRingView: UIView = {
        let view = UIView()
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithPrimary.withAlphaComponent(0.25).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var innerRingView: UIView = {
        let view = UIView()
        view.layer.borderWidth = WraithBorderWidth.hairline
        view.layer.borderColor = UIColor.wraithSecondary.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var coreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = WraithRadius.radius2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .wraithPrimary
        view.layer.cornerRadius = WraithRadius.radius2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let coreGradientLayer = CAGradientLayer()

    // MARK: - Properties

    private static let messages = [
        "Tercihlerin analiz ediliyor...",
        "Karakter analizinle eşleştiriliyor...",
        "Gün gün rota planlanıyor...",
        "Saat saat aktiviteler seçiliyor...",
        "Bütçe tahmini hesaplanıyor...",
        "Son rötuşlar yapılıyor..."
    ]
    private var messageTimer: Timer?
    private var messageIndex = 0

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        outerRingView.layer.cornerRadius = outerRingView.bounds.height / 2
        innerRingView.layer.cornerRadius = innerRingView.bounds.height / 2
        coreView.layer.cornerRadius = coreView.bounds.height / 2
        coreGradientLayer.frame = coreView.bounds
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubview(outerRingView)
        addSubview(innerRingView)
        addSubview(coreView)
        addSubview(messageLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)

        coreGradientLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        coreGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        coreGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        coreGradientLayer.cornerRadius = WraithRadius.radius24
        coreView.layer.insertSublayer(coreGradientLayer, at: 0)

        NSLayoutConstraint.activate([
            outerRingView.widthAnchor.constraint(equalToConstant: 140),
            outerRingView.heightAnchor.constraint(equalToConstant: 140),
            outerRingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerRingView.topAnchor.constraint(equalTo: topAnchor),

            innerRingView.widthAnchor.constraint(equalToConstant: 100),
            innerRingView.heightAnchor.constraint(equalToConstant: 100),
            innerRingView.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            innerRingView.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),

            coreView.widthAnchor.constraint(equalToConstant: 48),
            coreView.heightAnchor.constraint(equalToConstant: 48),
            coreView.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            coreView.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),

            messageLabel.topAnchor.constraint(equalTo: outerRingView.bottomAnchor, constant: WraithSpacing.space32),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space40),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space40),

            progressTrackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: WraithSpacing.space24),
            progressTrackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressTrackView.widthAnchor.constraint(equalToConstant: 140),
            progressTrackView.heightAnchor.constraint(equalToConstant: 4),
            progressTrackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: 0.5)
        ])
    }

    // MARK: - Public

    func startAnimating() {
        messageIndex = 0
        messageLabel.text = Self.messages[0]

        let rotateClockwise = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateClockwise.fromValue = 0
        rotateClockwise.toValue = CGFloat.pi * 2
        rotateClockwise.duration = 4
        rotateClockwise.repeatCount = .infinity
        outerRingView.layer.add(rotateClockwise, forKey: "rotate")

        let rotateCounterClockwise = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateCounterClockwise.fromValue = 0
        rotateCounterClockwise.toValue = -CGFloat.pi * 2
        rotateCounterClockwise.duration = 3
        rotateCounterClockwise.repeatCount = .infinity
        innerRingView.layer.add(rotateCounterClockwise, forKey: "rotate")

        coreView.transform = .identity
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.coreView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }

        progressFillView.transform = CGAffineTransform(translationX: -progressTrackView.bounds.width, y: 0)
        UIView.animate(withDuration: 0.9, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.progressFillView.transform = CGAffineTransform(translationX: self.progressTrackView.bounds.width, y: 0)
        }

        messageTimer?.invalidate()
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { [weak self] _ in
            self?.showNextMessage()
        }
    }

    func stopAnimating() {
        messageTimer?.invalidate()
        messageTimer = nil
        outerRingView.layer.removeAllAnimations()
        innerRingView.layer.removeAllAnimations()
        coreView.layer.removeAllAnimations()
        progressFillView.layer.removeAllAnimations()
    }

    // MARK: - Private

    private func showNextMessage() {
        messageIndex = (messageIndex + 1) % Self.messages.count
        UIView.transition(with: messageLabel, duration: 0.35, options: .transitionCrossDissolve) {
            self.messageLabel.text = Self.messages[self.messageIndex]
        }
    }
}

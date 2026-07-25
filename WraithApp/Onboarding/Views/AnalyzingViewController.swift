//
//  AnalyzingViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class AnalyzingViewController: UIViewController {

    private let outerRingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.wraithPrimary.withAlphaComponent(0.25).cgColor
        return view
    }()

    private let innerRingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.wraithSecondary.withAlphaComponent(0.3).cgColor
        return view
    }()

    private let coreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Seyahat Kimliğiniz Oluşturuluyor"
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .wraithOnSurface
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yapay zekamız cevaplarınızı analiz ederek size özel rotalar hazırlıyor."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .wraithOnSurfaceVariant
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithSurfaceVariant
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        view.layer.cornerRadius = 2
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        outerRingView.layer.cornerRadius = outerRingView.bounds.height / 2
        innerRingView.layer.cornerRadius = innerRingView.bounds.height / 2
        coreView.layer.cornerRadius = coreView.bounds.height / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimations()
    }

    private func setupLayout() {
        view.addSubview(outerRingView)
        view.addSubview(innerRingView)
        view.addSubview(coreView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)

        let coreGradientLayer = CAGradientLayer()
        coreGradientLayer.colors = [UIColor.wraithPrimary.cgColor, UIColor.wraithSecondary.cgColor]
        coreGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        coreGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        coreGradientLayer.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        coreGradientLayer.cornerRadius = 28
        coreView.layer.insertSublayer(coreGradientLayer, at: 0)

        NSLayoutConstraint.activate([
            outerRingView.widthAnchor.constraint(equalToConstant: 176),
            outerRingView.heightAnchor.constraint(equalToConstant: 176),
            outerRingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outerRingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),

            innerRingView.widthAnchor.constraint(equalToConstant: 128),
            innerRingView.heightAnchor.constraint(equalToConstant: 128),
            innerRingView.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            innerRingView.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),

            coreView.widthAnchor.constraint(equalToConstant: 56),
            coreView.heightAnchor.constraint(equalToConstant: 56),
            coreView.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            coreView.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: outerRingView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            progressTrackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            progressTrackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressTrackView.widthAnchor.constraint(equalToConstant: 160),
            progressTrackView.heightAnchor.constraint(equalToConstant: 4),

            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),
            progressFillView.widthAnchor.constraint(equalTo: progressTrackView.widthAnchor, multiplier: 0.55)
        ])
    }

    private func startAnimations() {
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

        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.coreView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }

        progressFillView.transform = CGAffineTransform(translationX: -progressTrackView.bounds.width, y: 0)
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.progressFillView.transform = CGAffineTransform(translationX: self.progressTrackView.bounds.width, y: 0)
        }
    }
}

//
//  HomeViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class HomeViewController: UIViewController {

    var onRequestRetakeOnboarding: (() -> Void)?
    var onRequestCreateTrip: (() -> Void)?

    private let createTripButton = GradientCapsuleButton(title: "Yeni Seyahat Oluştur")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Voya"
        setupNavigationButtons()
        setupLayout()
        setupActions()
    }

    private func setupNavigationButtons() {
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapProfile)
        )
        profileButton.tintColor = .wraithPrimary

        navigationItem.rightBarButtonItem = profileButton
    }

    private func setupLayout() {
        view.addSubview(createTripButton)

        NSLayoutConstraint.activate([
            createTripButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: WraithSpacing.space24),
            createTripButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -WraithSpacing.space24),
            createTripButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -WraithSpacing.space24)
        ])
    }

    private func setupActions() {
        createTripButton.addTarget(self, action: #selector(didTapCreateTrip), for: .touchUpInside)
    }

    @objc private func didTapProfile() {
        let profileVC = ProfileViewController()
        profileVC.onRequestRetakeOnboarding = onRequestRetakeOnboarding
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc private func didTapCreateTrip() {
        onRequestCreateTrip?()
    }
}

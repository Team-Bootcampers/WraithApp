//
//  HomeViewController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class HomeViewController: UIViewController {

    var onRequestRetakeOnboarding: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wraithBackground
        title = "Voya"
        setupNavigationButtons()
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

    @objc private func didTapProfile() {
        let profileVC = ProfileViewController()
        profileVC.onRequestRetakeOnboarding = onRequestRetakeOnboarding
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

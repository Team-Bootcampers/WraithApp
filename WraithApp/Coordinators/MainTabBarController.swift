//
//  MainTabBarController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit
import NetworkManager

final class MainTabBarController: UITabBarController {

    // MARK: - Properties

    private let networkManager: NetworkManagerProtocol

    // MARK: - Init

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    // MARK: - Setup

    private func setupViewControllers() {

    }
}

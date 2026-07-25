//
//  AppCoordinator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit
import NetworkManager

protocol Coordinator: AnyObject {
    func start()
}


final class AppCoordinator: Coordinator {

    // MARK: - Properties

    private let window: UIWindow
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
        self.networkManager = NetworkManager()
    }

    // MARK: - Coordinator

    func start() {
        
        let rootVC = ViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
         
    }
}

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
    }
}

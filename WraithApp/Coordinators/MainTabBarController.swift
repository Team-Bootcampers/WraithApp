//
//  MainTabBarController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Root tab bar shown after onboarding: Anasayfa, Yeni Seyahat, Seyahatlerim, Profil.
/// Each tab's own screen keeps whatever navigation-bar buttons it already defines
/// (e.g. Home's top-right profile icon and its own "Yeni Seyahat Oluştur" button).
final class MainTabBarController: UITabBarController {

    var onRequestRetakeOnboarding: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
    }

    private func setupAppearance() {
        tabBar.tintColor = .wraithPrimary
        tabBar.unselectedItemTintColor = .wraithOnSurfaceVariant

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .wraithSurface
        appearance.shadowColor = .wraithOutlineVariant

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        let homeVC = HomeViewController()
        homeVC.onRequestRetakeOnboarding = { [weak self] in
            self?.onRequestRetakeOnboarding?()
        }
        let homeTab = wrap(
            homeVC,
            title: "Anasayfa",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let tripCreationVC = TripCreationViewController()
        let tripCreationTab = wrap(
            tripCreationVC,
            title: "Yeni Seyahat",
            image: UIImage(systemName: "suitcase"),
            selectedImage: UIImage(systemName: "suitcase.fill")
        )

        let myTripsTab = wrap(
            MyTripsViewController(),
            title: "Seyahatlerim",
            image: UIImage(systemName: "airplane"),
            selectedImage: UIImage(systemName: "airplane.circle.fill")
        )

        tripCreationVC.onTripSaved = { [weak self, weak myTripsTab] savedTrip in
            guard let self, let myTripsTab else { return }
            if let index = self.viewControllers?.firstIndex(of: myTripsTab) {
                self.selectedIndex = index
            }
            myTripsTab.popToRootViewController(animated: false)
            let summaryViewModel = TripSummaryViewModel(trip: savedTrip)
            myTripsTab.pushViewController(TripSummaryViewController(viewModel: summaryViewModel), animated: true)
        }

        let profileVC = ProfileViewController()
        profileVC.onRequestRetakeOnboarding = { [weak self] in
            self?.onRequestRetakeOnboarding?()
        }
        let profileTab = wrap(
            profileVC,
            title: "Profil",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill")
        )

        viewControllers = [homeTab, tripCreationTab, myTripsTab, profileTab]
    }

    private func wrap(_ viewController: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?) -> UINavigationController {
        viewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        return UINavigationController(rootViewController: viewController)
    }
}

//
//  MainTabBarController.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

/// Root tab bar shown after onboarding: Anasayfa, Yeni Seyahat, Seyahatlerim, Profil.
final class MainTabBarController: UITabBarController {

    enum InitialTab {
        case home
        case tripCreation
    }

    var onRequestRetakeOnboarding: (() -> Void)?

    private let initialTab: InitialTab

    init(initialTab: InitialTab = .home) {
        self.initialTab = initialTab
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let myTripsTab = wrap(
            MyTripsViewController(),
            title: "Seyahatlerim",
            image: UIImage(systemName: "airplane"),
            selectedImage: UIImage(systemName: "airplane.circle.fill")
        )

        let showSavedTrip: (SavedTrip) -> Void = { [weak self, weak myTripsTab] savedTrip in
            guard let self, let myTripsTab else { return }
            // Unwind whichever tab produced the trip so returning to it later starts clean.
            (self.selectedViewController as? UINavigationController)?.popToRootViewController(animated: false)

            if let index = self.viewControllers?.firstIndex(of: myTripsTab) {
                self.selectedIndex = index
            }
            myTripsTab.popToRootViewController(animated: false)
            let summaryViewModel = TripSummaryViewModel(trip: savedTrip)
            myTripsTab.pushViewController(TripSummaryViewController(viewModel: summaryViewModel), animated: true)
        }

        let homeVC = HomeViewController()
        let homeTab = wrap(
            homeVC,
            title: "Anasayfa",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let tripCreationVC = TripCreationViewController()
        tripCreationVC.onTripSaved = showSavedTrip
        let tripCreationTab = wrap(
            tripCreationVC,
            title: "Yeni Seyahat",
            image: UIImage(systemName: "suitcase"),
            selectedImage: UIImage(systemName: "suitcase.fill")
        )

        let profileVC = ProfileViewController()
        profileVC.onRequestRetakeOnboarding = { [weak self] in
            self?.onRequestRetakeOnboarding?()
        }
        profileVC.onTripSaved = showSavedTrip
        let profileTab = wrap(
            profileVC,
            title: "Profil",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill")
        )

        viewControllers = [homeTab, tripCreationTab, myTripsTab, profileTab]

        switch initialTab {
        case .home:
            break
        case .tripCreation:
            selectedIndex = 1
        }
    }

    private func wrap(_ viewController: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?) -> UINavigationController {
        viewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        return UINavigationController(rootViewController: viewController)
    }
}

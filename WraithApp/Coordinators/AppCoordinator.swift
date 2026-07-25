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
    private var characterAnalysisCoordinator: CharacterAnalysisCoordinator?

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
        self.networkManager = NetworkManager()
    }

    // MARK: - Coordinator

    func start() {
        let introVC = OnboardingIntroViewController()
        introVC.onStart = { [weak self] in
            self?.showCharacterAnalysis()
        }

        window.rootViewController = introVC
        window.makeKeyAndVisible()
    }

    // MARK: - Navigation

    private func showCharacterAnalysis(initialAnswers: [QuizOption] = []) {
        let navigationController = UINavigationController()
        let coordinator = CharacterAnalysisCoordinator(navigationController: navigationController, initialAnswers: initialAnswers)
        coordinator.onCancelled = { [weak self] in
            self?.start()
        }
        coordinator.onFinished = { [weak self] answers in
            self?.showAnalyzing(in: navigationController, answers: answers)
        }

        characterAnalysisCoordinator = coordinator
        window.rootViewController = navigationController
        coordinator.start()
    }

    private func showAnalyzing(in navigationController: UINavigationController, answers: [QuizAnswer]) {
        let analyzingVC = AnalyzingViewController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(analyzingVC, animated: true)

        let submission = CharacterAnalysisSubmission(answers: answers)
        if let jsonData = submission.jsonData, let json = String(data: jsonData, encoding: .utf8) {
            print(json)
        }

        // TODO: Replace this simulated delay with a real POST of `submission.jsonData` to the analysis endpoint.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            self?.showTravelIdentity(in: navigationController, answers: answers)
        }
    }

    private func showTravelIdentity(in navigationController: UINavigationController, answers: [QuizAnswer]) {
        let selectedOptions = answers.map { QuizOption(title: $0.selectedOptionTitle, value: $0.selectedOptionValue) }
        let result = TravelProfileAnalyzer.analyze(answers: selectedOptions)
        let travelIdentityVC = TravelIdentityViewController(result: result)
        travelIdentityVC.onMakeFirstPlan = { [weak self] in
            self?.showMain()
        }
        travelIdentityVC.onEditProfile = { [weak self] in
            self?.showCharacterAnalysis(initialAnswers: selectedOptions)
        }
        navigationController.setViewControllers([travelIdentityVC], animated: true)
    }

    private func showMain() {
        let mainTabBarController = MainTabBarController(networkManager: networkManager)
        window.rootViewController = mainTabBarController
    }
}

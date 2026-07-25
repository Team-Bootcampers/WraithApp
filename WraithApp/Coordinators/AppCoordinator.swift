//
//  AppCoordinator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}


final class AppCoordinator: Coordinator {

    // MARK: - Properties

    private let window: UIWindow
    private var characterAnalysisCoordinator: CharacterAnalysisCoordinator?

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Coordinator

    func start() {
        let splashVC = SplashViewController()
        splashVC.onFinish = { [weak self] in
            self?.showOnboardingIntro()
        }

        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }

    // MARK: - Navigation

    private func showOnboardingIntro() {
        let introVC = OnboardingIntroViewController()
        introVC.onStart = { [weak self] in
            self?.showCharacterAnalysis()
        }

        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve) {
            self.window.rootViewController = introVC
        }
    }

    private func showCharacterAnalysis(initialAnswers: [QuizOption] = []) {
        let navigationController = UINavigationController()
        let coordinator = CharacterAnalysisCoordinator(navigationController: navigationController, initialAnswers: initialAnswers)
        coordinator.onCancelled = { [weak self] in
            self?.start()
        }
        coordinator.onFinished = { [weak self] answers in
            self?.showAnalyzing(in: navigationController, answers: answers)
        }
        coordinator.onSkipped = { [weak self] in
            // The user explicitly declined to finish onboarding this time, so drop any
            // previously-saved answers rather than letting stale data get synced on next login.
            QuizAnswerStore.shared.clear()
            self?.showMain()
        }

        characterAnalysisCoordinator = coordinator
        window.rootViewController = navigationController
        coordinator.start()
    }

    private func showAnalyzing(in navigationController: UINavigationController, answers: [QuizAnswer]) {
        let analyzingVC = AnalyzingViewController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(analyzingVC, animated: true)

        QuizAnswerStore.shared.save(answers)

        if let userId = UserSession.shared.userId, let token = UserSession.shared.idToken, let dto = OnboardingMapper.map(answers) {
            Task {
                do {
                    let user = try await UserAPI.saveOnboarding(userId, answers: dto, token: token)
                    UserSession.shared.updateOnboardedRemote(user.isOnboarded)
                } catch {
                    // Best-effort sync; the answers remain safely stored locally for a later retry.
                }
            }
        }

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
        let homeVC = HomeViewController()
        homeVC.onRequestRetakeOnboarding = { [weak self] in
            self?.showCharacterAnalysis(initialAnswers: QuizAnswerStore.shared.loadSelectedOptions())
        }
        window.rootViewController = UINavigationController(rootViewController: homeVC)
    }
}

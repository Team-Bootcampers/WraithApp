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
            TravelPersonalityStore.clear()
            self?.showMain()
        }

        characterAnalysisCoordinator = coordinator
        window.rootViewController = navigationController
        coordinator.start()
    }

    private enum CharacterAnalysisError: LocalizedError {
        case notAuthenticated
        case emptyAnalysis

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "Analiz için giriş yapmış olman gerekiyor."
            case .emptyAnalysis:
                return "Yapay zeka bir analiz döndürmedi. Lütfen tekrar dene."
            }
        }
    }

    private func showAnalyzing(in navigationController: UINavigationController, answers: [QuizAnswer]) {
        let analyzingVC = AnalyzingViewController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(analyzingVC, animated: true)

        QuizAnswerStore.shared.save(answers)
        runCharacterAnalysis(in: navigationController, answers: answers)
    }

    private func runCharacterAnalysis(in navigationController: UINavigationController, answers: [QuizAnswer]) {
        let selectedOptions = answers.map { QuizOption(title: $0.selectedOptionTitle, value: $0.selectedOptionValue) }
        let dto = OnboardingMapper.map(answers)

        if let userId = UserSession.shared.userId, let token = UserSession.shared.idToken, let dto {
            Task {
                do {
                    let user = try await UserAPI.saveOnboarding(userId, answers: dto, token: token)
                    UserSession.shared.updateOnboardedRemote(user.isOnboarded)
                } catch {
                    // Best-effort sync; the answers remain safely stored locally for a later retry.
                }
            }
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.fetchTravelIdentityResult(selectedOptions: selectedOptions, dto: dto)
                self.showTravelIdentity(in: navigationController, result: result, selectedOptions: selectedOptions)
            } catch {
                self.showAnalysisFailure(in: navigationController, answers: answers, error: error)
            }
        }
    }

    /// The character-analysis text always comes from `/ai/travel-personality` — there is
    /// deliberately no locally-generated substitute, so any failure (network, auth, empty
    /// response) surfaces as an error instead of silently falling back to canned copy.
    private func fetchTravelIdentityResult(selectedOptions: [QuizOption], dto: OnboardingAnswersDto?) async throws -> TravelIdentityResult {
        guard let dto, let token = UserSession.shared.idToken else {
            throw CharacterAnalysisError.notAuthenticated
        }

        async let minimumDisplayDuration: Void? = try? Task.sleep(nanoseconds: 1_400_000_000)
        async let responseTask = AIAPI.travelPersonality(answers: dto, token: token)

        let analysis = try await responseTask.analysis
        _ = await minimumDisplayDuration

        guard !analysis.isEmpty else { throw CharacterAnalysisError.emptyAnalysis }

        TravelPersonalityStore.save(analysis)

        // Title/summary/insight-label copy is just short, deterministic UI chrome around the
        // AI's write-up (the backend doesn't return them) — not a substitute analysis.
        let labels = TravelProfileAnalyzer.analyze(answers: selectedOptions)
        return TravelIdentityResult(
            title: labels.title,
            summary: labels.summary,
            insightTitle: labels.insightTitle,
            insightDescription: analysis
        )
    }

    private func showAnalysisFailure(in navigationController: UINavigationController, answers: [QuizAnswer], error: Error) {
        let alert = UIAlertController(
            title: "Analiz Başarısız Oldu",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tekrar Dene", style: .default) { [weak self] _ in
            self?.runCharacterAnalysis(in: navigationController, answers: answers)
        })
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel) { [weak self] _ in
            self?.start()
        })
        navigationController.topViewController?.present(alert, animated: true)
    }

    private func showTravelIdentity(in navigationController: UINavigationController, result: TravelIdentityResult, selectedOptions: [QuizOption]) {
        let travelIdentityVC = TravelIdentityViewController(result: result)
        travelIdentityVC.onMakeFirstPlan = { [weak self] in
            self?.showMain(initialTab: .tripCreation)
        }
        travelIdentityVC.onEditProfile = { [weak self] in
            self?.showCharacterAnalysis(initialAnswers: selectedOptions)
        }
        navigationController.setViewControllers([travelIdentityVC], animated: true)
    }

    private func showMain(initialTab: MainTabBarController.InitialTab = .home) {
        let tabBarController = MainTabBarController(initialTab: initialTab)
        tabBarController.onRequestRetakeOnboarding = { [weak self] in
            self?.showCharacterAnalysis(initialAnswers: QuizAnswerStore.shared.loadSelectedOptions())
        }
        window.rootViewController = tabBarController
    }
}

//
//  AuthCoordinator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class AuthCoordinator: Coordinator {

    // MARK: - Properties

    private let presentingViewController: UIViewController
    private let navigationController = UINavigationController()

    var onFinished: (() -> Void)?

    // MARK: - Init

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    // MARK: - Coordinator

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        showLogin()
        presentingViewController.present(navigationController, animated: true)
    }

    // MARK: - Navigation

    private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.onLogin = { [weak self] email, password in
            let response = try await AuthAPI.login(email: email, password: password)
            guard let user = response.user else {
                throw APIError.decoding(NSError(domain: "AuthCoordinator", code: -1))
            }
            UserSession.shared.login(user: user, idToken: response.idToken, refreshToken: response.refreshToken)
            await self?.syncOnboardingIfNeeded()
            await TripSyncService().syncAllSavedTrips()
            self?.finish()
        }
        loginVC.onSwitchToSignUp = { [weak self] in
            self?.showSignUp()
        }
        loginVC.onClose = { [weak self] in
            self?.finish()
        }
        navigationController.setViewControllers([loginVC], animated: false)
    }

    private func showSignUp() {
        let signUpVC = SignUpViewController()
        signUpVC.onSignUp = { [weak self] name, email, password in
            _ = try await AuthAPI.signUp(email: email, password: password, displayName: name.isEmpty ? nil : name)
            let loginResponse = try await AuthAPI.login(email: email, password: password)
            guard let user = loginResponse.user else {
                throw APIError.decoding(NSError(domain: "AuthCoordinator", code: -1))
            }
            UserSession.shared.login(user: user, idToken: loginResponse.idToken, refreshToken: loginResponse.refreshToken)
            await self?.syncOnboardingIfNeeded()
            await TripSyncService().syncAllSavedTrips()
            self?.finish()
        }
        signUpVC.onSwitchToLogin = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        signUpVC.onClose = { [weak self] in
            self?.finish()
        }
        navigationController.pushViewController(signUpVC, animated: true)
    }

    /// Pushes any locally-saved quiz answers (taken as a guest, before login) up to the backend.
    private func syncOnboardingIfNeeded() async {
        guard
            let userId = UserSession.shared.userId,
            let token = UserSession.shared.idToken,
            let answers = QuizAnswerStore.shared.loadSavedAnswers(),
            let dto = OnboardingMapper.map(answers)
        else { return }

        do {
            let user = try await UserAPI.saveOnboarding(userId, answers: dto, token: token)
            UserSession.shared.updateOnboardedRemote(user.isOnboarded)
        } catch {
            // Best-effort sync; the answers remain safely stored locally for a later retry.
        }
    }

    private func finish() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.onFinished?()
        }
    }
}

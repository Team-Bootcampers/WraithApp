//
//  CharacterAnalysisCoordinator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class CharacterAnalysisCoordinator: NSObject, Coordinator {

    // MARK: - Callbacks

    var onCancelled: (() -> Void)?
    var onFinished: (([QuizAnswer]) -> Void)?
    var onSkipped: (() -> Void)?

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let questions: [QuizQuestion]
    private var answers: [QuizOption?]
    private var transitionVehicleIndex = 0

    // MARK: - Init

    init(
        navigationController: UINavigationController,
        questions: [QuizQuestion] = CharacterAnalysisQuestions.all,
        initialAnswers: [QuizOption] = []
    ) {
        self.navigationController = navigationController
        self.questions = questions
        self.answers = (0..<questions.count).map { initialAnswers.indices.contains($0) ? initialAnswers[$0] : nil }
        super.init()
    }

    // MARK: - Coordinator

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.delegate = self
        showQuestion(at: 0)
    }

    // MARK: - Navigation

    private func showQuestion(at index: Int) {
        let question = questions[index]
        let questionVC = CharacterAnalysisQuestionViewController(
            question: question,
            questionIndex: index + 1,
            totalQuestions: questions.count,
            initialSelection: answers[index]
        )

        questionVC.onBack = { [weak self] in
            guard let self else { return }
            if index == 0 {
                self.onCancelled?()
            } else {
                self.navigationController.popViewController(animated: true)
            }
        }

        questionVC.onNext = { [weak self] selectedOption in
            self?.advance(from: index, selection: selectedOption)
        }

        questionVC.onSkip = { [weak self] in
            self?.onSkipped?()
        }

        if index == 0 {
            navigationController.setViewControllers([questionVC], animated: false)
        } else {
            navigationController.pushViewController(questionVC, animated: true)
        }
    }

    private func advance(from index: Int, selection: QuizOption?) {
        answers[index] = selection
        if index + 1 < questions.count {
            showQuestion(at: index + 1)
        } else {
            let quizAnswers = questions.indices.compactMap { questionIndex -> QuizAnswer? in
                guard let answer = answers[questionIndex] else { return nil }
                return QuizAnswer(
                    questionIndex: questionIndex + 1,
                    question: questions[questionIndex].title,
                    selectedOptionTitle: answer.title,
                    selectedOptionValue: answer.value
                )
            }
            onFinished?(quizAnswers)
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension CharacterAnalysisCoordinator: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            operation != .none,
            fromVC is CharacterAnalysisQuestionViewController,
            toVC is CharacterAnalysisQuestionViewController
        else {
            return nil
        }
        let vehicles = TowVehicle.allCases
        let vehicle = vehicles[transitionVehicleIndex % vehicles.count]
        transitionVehicleIndex += 1
        return VehicleTowTransition(operation: operation, vehicle: vehicle)
    }
}

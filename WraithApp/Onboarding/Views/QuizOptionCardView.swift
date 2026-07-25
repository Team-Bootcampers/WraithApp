//
//  QuizOptionCardView.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class QuizOptionCardView: UIControl {

    let option: QuizOption

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    private let radioView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 11
        view.layer.borderWidth = 2
        return view
    }()

    private let radioFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        view.layer.cornerRadius = 5
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .wraithOnSurface
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    init(option: QuizOption) {
        self.option = option
        super.init(frame: .zero)
        titleLabel.text = option.title
        setupLayout()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.shadowColor = UIColor.wraithPrimary.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)

        radioView.addSubview(radioFillView)
        addSubview(radioView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            radioView.widthAnchor.constraint(equalToConstant: 22),
            radioView.heightAnchor.constraint(equalToConstant: 22),
            radioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            radioView.centerYAnchor.constraint(equalTo: centerYAnchor),

            radioFillView.centerXAnchor.constraint(equalTo: radioView.centerXAnchor),
            radioFillView.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            radioFillView.widthAnchor.constraint(equalToConstant: 10),
            radioFillView.heightAnchor.constraint(equalToConstant: 10),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: radioView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func updateAppearance() {
        if isSelected {
            backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.08)
            layer.borderColor = UIColor.wraithPrimary.cgColor
            layer.borderWidth = 2
            radioView.layer.borderColor = UIColor.wraithPrimary.cgColor
            radioFillView.alpha = 1
            radioFillView.transform = .identity
            titleLabel.textColor = .wraithPrimary
        } else {
            backgroundColor = .wraithSurface
            layer.borderColor = UIColor.wraithOutlineVariant.cgColor
            layer.borderWidth = 1
            radioView.layer.borderColor = UIColor.wraithOutline.cgColor
            radioFillView.alpha = 0
            radioFillView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            titleLabel.textColor = .wraithOnSurface
        }
    }
}

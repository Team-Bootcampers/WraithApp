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
        view.layer.cornerRadius = WraithRadius.radius11
        view.layer.borderWidth = WraithBorderWidth.selected
        return view
    }()

    private let radioFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .wraithPrimary
        view.layer.cornerRadius = WraithRadius.radius5
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
        layer.cornerRadius = WraithRadius.radius12
        layer.borderWidth = WraithBorderWidth.hairline
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
            radioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            radioView.centerYAnchor.constraint(equalTo: centerYAnchor),

            radioFillView.centerXAnchor.constraint(equalTo: radioView.centerXAnchor),
            radioFillView.centerYAnchor.constraint(equalTo: radioView.centerYAnchor),
            radioFillView.widthAnchor.constraint(equalToConstant: 10),
            radioFillView.heightAnchor.constraint(equalToConstant: 10),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: WraithSpacing.space16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WraithSpacing.space16),
            titleLabel.leadingAnchor.constraint(equalTo: radioView.trailingAnchor, constant: WraithSpacing.space12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16)
        ])
    }

    private func updateAppearance() {
        if isSelected {
            backgroundColor = UIColor.wraithPrimary.withAlphaComponent(0.08)
            layer.borderColor = UIColor.wraithPrimary.cgColor
            layer.borderWidth = WraithBorderWidth.selected
            radioView.layer.borderColor = UIColor.wraithPrimary.cgColor
            radioFillView.alpha = 1
            radioFillView.transform = .identity
            titleLabel.textColor = .wraithPrimary
        } else {
            backgroundColor = .wraithSurface
            layer.borderColor = UIColor.wraithOutlineVariant.cgColor
            layer.borderWidth = WraithBorderWidth.hairline
            radioView.layer.borderColor = UIColor.wraithOutline.cgColor
            radioFillView.alpha = 0
            radioFillView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            titleLabel.textColor = .wraithOnSurface
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.shadowColor = UIColor.wraithPrimary.cgColor
        updateAppearance()
    }
}

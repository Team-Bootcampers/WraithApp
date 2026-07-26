//
//  WraithTextField.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

final class WraithTextField: UIView {

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.textColor = .wraithOnSurface
        field.tintColor = .wraithPrimary
        return field
    }()

    private let toggleSecureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .wraithOnSurfaceVariant
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        return button
    }()

    init(placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup(placeholder: placeholder, isSecure: isSecure, keyboardType: keyboardType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(placeholder: String, isSecure: Bool, keyboardType: UIKeyboardType) {
        backgroundColor = .wraithSurface
        layer.cornerRadius = WraithRadius.radius12
        layer.borderWidth = WraithBorderWidth.hairline
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.wraithOnSurfaceVariant]
        )
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        addSubview(textField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WraithSpacing.space16),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        if isSecure {
            toggleSecureButton.addTarget(self, action: #selector(toggleSecureEntry), for: .touchUpInside)
            addSubview(toggleSecureButton)

            NSLayoutConstraint.activate([
                textField.trailingAnchor.constraint(equalTo: toggleSecureButton.leadingAnchor, constant: -WraithSpacing.space8),
                toggleSecureButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16),
                toggleSecureButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                toggleSecureButton.widthAnchor.constraint(equalToConstant: 24),
                toggleSecureButton.heightAnchor.constraint(equalToConstant: 24)
            ])
        } else {
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WraithSpacing.space16).isActive = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.wraithOutlineVariant.cgColor
    }

    @objc private func toggleSecureEntry() {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye" : "eye.slash"
        toggleSecureButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

//
//  CredentialValidator.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum CredentialValidationError: LocalizedError {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case passwordTooShort(minLength: Int)

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Lütfen e-posta adresini gir."
        case .invalidEmail:
            return "Geçerli bir e-posta adresi gir."
        case .emptyPassword:
            return "Lütfen şifreni gir."
        case .passwordTooShort(let minLength):
            return "Şifre en az \(minLength) karakter olmalı."
        }
    }
}

/// Client-side checks that mirror the backend's own rules (see `SignUpDto.password`'s
/// `minLength: 6`), so obviously-invalid input is caught before a network round trip.
enum CredentialValidator {

    private static let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    static func validateEmail(_ email: String) throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CredentialValidationError.emptyEmail }
        guard trimmed.range(of: emailRegex, options: .regularExpression) != nil else {
            throw CredentialValidationError.invalidEmail
        }
    }

    static func validatePassword(_ password: String, minLength: Int = 1) throws {
        guard !password.isEmpty else { throw CredentialValidationError.emptyPassword }
        guard password.count >= minLength else {
            throw CredentialValidationError.passwordTooShort(minLength: minLength)
        }
    }
}

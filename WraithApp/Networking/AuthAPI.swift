//
//  AuthAPI.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct UserProfileDto: Decodable {
    let id: String
    let firebaseUid: String
    let email: String
    let displayName: String?
    let createdAt: String
}

private struct SignUpRequestDto: Encodable {
    let email: String
    let password: String
    let displayName: String?
}

struct SignUpResponseDto: Decodable {
    let message: String
    let user: UserProfileDto
}

private struct LoginRequestDto: Encodable {
    let email: String
    let password: String
}

struct LoginResponseDto: Decodable {
    let idToken: String
    let refreshToken: String
    let expiresIn: String
    let user: UserProfileDto?
}

/// Wraps `/auth/signup` and `/auth/login` from the CoreBackendKit API.
enum AuthAPI {

    static func signUp(email: String, password: String, displayName: String?) async throws -> SignUpResponseDto {
        try await APIClient.shared.request(
            path: "/auth/signup",
            method: "POST",
            body: SignUpRequestDto(email: email, password: password, displayName: displayName)
        )
    }

    static func login(email: String, password: String) async throws -> LoginResponseDto {
        try await APIClient.shared.request(
            path: "/auth/login",
            method: "POST",
            body: LoginRequestDto(email: email, password: password)
        )
    }
}

//
//  UserSession.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

/// Persists the signed-in user's identity and auth tokens across launches.
/// Tokens live in the Keychain; the rest is small, non-sensitive profile data in UserDefaults.
final class UserSession {

    static let shared = UserSession()

    private enum Keys {
        static let userId = "com.voya.session.userId"
        static let email = "com.voya.session.email"
        static let displayName = "com.voya.session.displayName"
        static let isOnboardedRemote = "com.voya.session.isOnboardedRemote"
    }

    private enum KeychainKeys {
        static let idToken = "idToken"
        static let refreshToken = "refreshToken"
    }

    private(set) var userId: String? {
        didSet { persist(userId, forKey: Keys.userId) }
    }

    private(set) var email: String? {
        didSet { persist(email, forKey: Keys.email) }
    }

    private(set) var storedDisplayName: String? {
        didSet { persist(storedDisplayName, forKey: Keys.displayName) }
    }

    private(set) var isOnboardedRemote: Bool {
        didSet { UserDefaults.standard.set(isOnboardedRemote, forKey: Keys.isOnboardedRemote) }
    }

    private(set) var idToken: String?
    private(set) var refreshToken: String?

    var isLoggedIn: Bool { userId != nil }

    var displayName: String { storedDisplayName ?? email ?? "Misafir Kullanıcı" }

    private init() {
        userId = UserDefaults.standard.string(forKey: Keys.userId)
        email = UserDefaults.standard.string(forKey: Keys.email)
        storedDisplayName = UserDefaults.standard.string(forKey: Keys.displayName)
        isOnboardedRemote = UserDefaults.standard.bool(forKey: Keys.isOnboardedRemote)
        idToken = KeychainStore.get(KeychainKeys.idToken)
        refreshToken = KeychainStore.get(KeychainKeys.refreshToken)
    }

    /// Stores the session after a successful `/auth/login` or `/auth/signup` + login.
    func login(user: UserProfileDto, idToken: String, refreshToken: String) {
        self.userId = user.id
        self.email = user.email
        self.storedDisplayName = user.displayName
        self.idToken = idToken
        self.refreshToken = refreshToken
        KeychainStore.set(idToken, forKey: KeychainKeys.idToken)
        KeychainStore.set(refreshToken, forKey: KeychainKeys.refreshToken)
    }

    func updateOnboardedRemote(_ isOnboarded: Bool) {
        isOnboardedRemote = isOnboarded
    }

    func logout() {
        userId = nil
        email = nil
        storedDisplayName = nil
        isOnboardedRemote = false
        idToken = nil
        refreshToken = nil
        KeychainStore.remove(KeychainKeys.idToken)
        KeychainStore.remove(KeychainKeys.refreshToken)
    }

    private func persist(_ value: String?, forKey key: String) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

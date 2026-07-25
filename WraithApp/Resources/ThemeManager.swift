//
//  ThemeManager.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import UIKit

enum AppTheme: String {
    case light
    case dark

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Persists the user's chosen theme and applies it to the app's window,
/// so the whole app can switch between light and dark independent of the system setting.
final class ThemeManager {

    static let shared = ThemeManager()

    private enum Keys {
        static let selectedTheme = "com.voya.selectedTheme"
    }

    private(set) var currentTheme: AppTheme {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: Keys.selectedTheme) }
    }

    private weak var window: UIWindow?

    private init() {
        if let rawValue = UserDefaults.standard.string(forKey: Keys.selectedTheme),
           let theme = AppTheme(rawValue: rawValue) {
            currentTheme = theme
        } else {
            currentTheme = .light
        }
    }

    func attach(to window: UIWindow) {
        self.window = window
        window.overrideUserInterfaceStyle = currentTheme.interfaceStyle
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        guard let window else { return }
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve]) {
            window.overrideUserInterfaceStyle = theme.interfaceStyle
        }
    }

    func toggle() {
        setTheme(currentTheme == .light ? .dark : .light)
    }
}

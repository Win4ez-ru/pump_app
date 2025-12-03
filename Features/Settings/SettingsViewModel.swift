// Features/Settings/SettingsViewModel.swift
import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled = true
    @Published var isDarkModeEnabled = false
    @Published var isHapticFeedbackEnabled = true
    
    func saveSettings() {
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "dark_mode_enabled")
        UserDefaults.standard.set(isHapticFeedbackEnabled, forKey: "haptic_feedback_enabled")
    }
    
    func loadSettings() {
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "dark_mode_enabled")
        isHapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
    }
}

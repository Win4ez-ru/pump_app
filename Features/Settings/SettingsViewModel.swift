// Features/Settings/SettingsViewModel.swift
import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled = true
    @Published var isDarkModeEnabled = false
    @Published var isHapticFeedbackEnabled = true
    @Published var notificationPreferences: NotificationPreferences = .demo
    @Published var notifications: [ClientNotification] = ClientNotification.demo

    func saveSettings() {
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "dark_mode_enabled")
        UserDefaults.standard.set(isHapticFeedbackEnabled, forKey: "haptic_feedback_enabled")
        saveNotificationPreferences()
    }

    func loadSettings() {
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "dark_mode_enabled")
        isHapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "haptic_feedback_enabled")
        loadNotificationPreferences()
    }

    func updateNotificationPreferences(_ preferences: NotificationPreferences) {
        notificationPreferences = preferences
        saveNotificationPreferences()
    }

    func markAllNotificationsRead() {
        notifications = notifications.map { notification in
            var copy = notification
            copy.isUnread = false
            return copy
        }
    }

    private func saveNotificationPreferences() {
        guard let data = try? JSONEncoder().encode(notificationPreferences) else {
            return
        }

        UserDefaults.standard.set(data, forKey: "notification_preferences")
    }

    private func loadNotificationPreferences() {
        guard let data = UserDefaults.standard.data(forKey: "notification_preferences"),
              let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
            return
        }

        notificationPreferences = preferences
    }
}

struct NotificationPreferences: Codable, Equatable {
    var trainingReminders: Bool
    var trainerMessages: Bool
    var stepGoalReminders: Bool
    var nutritionReminders: Bool
    var achievementAlerts: Bool
    var reminderMinutesBeforeTraining: Int
    var quietHoursEnabled: Bool
    var quietHoursStart: Int
    var quietHoursEnd: Int

    static let demo = NotificationPreferences(
        trainingReminders: true,
        trainerMessages: true,
        stepGoalReminders: true,
        nutritionReminders: false,
        achievementAlerts: true,
        reminderMinutesBeforeTraining: 60,
        quietHoursEnabled: true,
        quietHoursStart: 22,
        quietHoursEnd: 8
    )
}

struct ClientNotification: Identifiable, Equatable {
    let id: String
    let title: String
    let message: String
    let time: Date
    let type: ClientNotificationType
    var isUnread: Bool

    static let demo: [ClientNotification] = [
        ClientNotification(
            id: "1",
            title: "Тренировка сегодня",
            message: "Онлайн-фулбоди в 19:30. Подготовьте коврик и воду.",
            time: Date().addingTimeInterval(-900),
            type: .training,
            isUnread: true
        ),
        ClientNotification(
            id: "2",
            title: "Сообщение от тренера",
            message: "Ника прислала план первой недели.",
            time: Date().addingTimeInterval(-3600),
            type: .message,
            isUnread: true
        ),
        ClientNotification(
            id: "3",
            title: "Цель по шагам",
            message: "Осталось 1 580 шагов до дневной цели.",
            time: Date().addingTimeInterval(-7200),
            type: .activity,
            isUnread: false
        ),
        ClientNotification(
            id: "4",
            title: "Новое достижение",
            message: "Серия 7 дней подряд открыта.",
            time: Date().addingTimeInterval(-86400),
            type: .achievement,
            isUnread: false
        )
    ]
}

enum ClientNotificationType: String {
    case training = "Тренировка"
    case message = "Сообщение"
    case activity = "Активность"
    case achievement = "Достижение"

    var icon: String {
        switch self {
        case .training:
            return "calendar.badge.clock"
        case .message:
            return "message.fill"
        case .activity:
            return "figure.walk"
        case .achievement:
            return "rosette"
        }
    }
}

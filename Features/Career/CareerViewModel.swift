import Foundation
import SwiftUI
import Combine

// TimePeriod выносим за пределы класса
enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"
    
    var id: String { self.rawValue }
}

class CareerViewModel: ObservableObject {
    @Published var selectedTimePeriod: TimePeriod = .month  // Убрали CareerViewModel.
    @Published var weeklyProgress: [WeeklyProgress] = []
    @Published var achievements: [Achievement] = []
    @Published var stats: CareerStats

    let healthMetrics: [HealthProgressMetric] = [
        HealthProgressMetric(title: "Шаги", value: "8 420", goal: "10 000", progress: 0.84, icon: "figure.walk", color: .green),
        HealthProgressMetric(title: "Активность", value: "48", goal: "60 мин", progress: 0.8, icon: "heart.fill", color: .red),
        HealthProgressMetric(title: "КБЖУ", value: "82%", goal: "плана", progress: 0.82, icon: "fork.knife", color: .orange)
    ]

    // Добавляем вычисляемое свойство для прогресса опыта
    var experienceProgress: Double {
        let experience = Double(stats.totalTrainings)
        let progress = experience.truncatingRemainder(dividingBy: 10) / 10.0
        return progress
    }
    
    // Добавляем статистику для периодов
    var currentPeriodStats: PeriodStats {
        switch selectedTimePeriod {
        case .day:
            return PeriodStats(trainings: 2, hours: 3.5, calories: 450, intensity: 7.5, avgSessionDuration: 105)
        case .week:
            return PeriodStats(trainings: 8, hours: 14.0, calories: 2100, intensity: 7.2, avgSessionDuration: 105)
        case .month:
            return PeriodStats(trainings: 22, hours: 38.5, calories: 5775, intensity: 7.0, avgSessionDuration: 105)
        case .year:
            return PeriodStats(trainings: 47, hours: 82.0, calories: 12450, intensity: 6.8, avgSessionDuration: 105)
        }
    }
    
    // Добавляем топ пользователей
    var topUsers: [TopUser] {
        return [
            TopUser(id: "1", name: "Алексей", trainings: 32, hours: 56, avatarColor: .blue, isCurrentUser: false),
            TopUser(id: "2", name: "Мария", trainings: 28, hours: 49, avatarColor: .pink, isCurrentUser: false),
            TopUser(id: "3", name: "Иван", trainings: 25, hours: 45, avatarColor: .green, isCurrentUser: false),
            TopUser(id: "4", name: "Вы", trainings: 22, hours: 38, avatarColor: .orange, isCurrentUser: true),
            TopUser(id: "5", name: "Дмитрий", trainings: 20, hours: 35, avatarColor: .purple, isCurrentUser: false)
        ]
    }
    
    init() {
        self.stats = CareerStats(
            totalTrainings: 47,
            totalHours: 82,
            currentStreak: 7,
            bestStreak: 14,
            caloriesTotal: 12450,
            consistency: 78.5
        )
        loadSampleData()
    }
    
    private func loadSampleData() {
        weeklyProgress = [
            WeeklyProgress(day: "ПН", completedTrainings: 2, targetTrainings: 2),
            WeeklyProgress(day: "ВТ", completedTrainings: 1, targetTrainings: 2),
            WeeklyProgress(day: "СР", completedTrainings: 2, targetTrainings: 2),
            WeeklyProgress(day: "ЧТ", completedTrainings: 2, targetTrainings: 2),
            WeeklyProgress(day: "ПТ", completedTrainings: 1, targetTrainings: 2),
            WeeklyProgress(day: "СБ", completedTrainings: 2, targetTrainings: 2),
            WeeklyProgress(day: "ВС", completedTrainings: 0, targetTrainings: 2)
        ]
        
        achievements = [
            Achievement(
                title: "Новичок",
                description: "Первая тренировка",
                icon: "trophy.fill",
                color: .orange,
                isUnlocked: true,
                progress: 1.0
            ),
            Achievement(
                title: "Стальной дух",
                description: "7 дней подряд",
                icon: "flame.fill",
                color: .red,
                isUnlocked: true,
                progress: 1.0
            ),
            Achievement(
                title: "Мастер",
                description: "10 часов тренировок",
                icon: "clock.fill",
                color: .blue,
                isUnlocked: false,
                progress: 0.82
            ),
            Achievement(
                title: "Легенда",
                description: "50 тренировок",
                icon: "crown.fill",
                color: .yellow,
                isUnlocked: false,
                progress: 0.94
            )
        ]
    }
    
    func refreshData() {
        loadSampleData()
    }
}

// MARK: - Модели данных

struct WeeklyProgress: Identifiable {
    let id = UUID()
    let day: String
    let completedTrainings: Int
    let targetTrainings: Int
    
    var progress: Double {
        Double(completedTrainings) / Double(targetTrainings)
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let progress: Double
}

struct HealthProgressMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let icon: String
    let color: Color
}

struct CareerStats {
    let totalTrainings: Int
    let totalHours: Int
    let currentStreak: Int
    let bestStreak: Int
    let caloriesTotal: Int
    let consistency: Double
    
    var level: Int {
        totalTrainings / 10 + 1
    }
    
    var experience: Int {
        totalTrainings * 100
    }
}

// Новая модель для статистики за период
struct PeriodStats {
    let trainings: Int
    let hours: Double
    let calories: Int
    let intensity: Double
    let avgSessionDuration: Int
}

// Новая модель для топ пользователей
struct TopUser: Identifiable {
    let id: String
    let name: String
    let trainings: Int
    let hours: Int
    let avatarColor: Color
    let isCurrentUser: Bool
}

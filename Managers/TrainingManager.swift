import Foundation
import Combine

@MainActor
class TrainingManager: ObservableObject {
    @Published var trainings: [Training] = []
    
    var nextTraining: Training? {
        trainings
            .filter { $0.isFuture }
            .sorted { $0.startTime < $1.startTime }
            .first
    }
    
    init() {
        loadSampleTrainings()
    }
    
    func addTraining(_ training: Training) {
        trainings.append(training)
        sortTrainings()
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
            sortTrainings()
        }
    }
    
    func deleteTraining(_ training: Training) {
        trainings.removeAll { $0.id == training.id }
    }
    
    func getTrainings(for date: Date) -> [Training] {
        let calendar = Calendar.current
        return trainings.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func sortTrainings() {
        trainings.sort { $0.startTime < $1.startTime }
    }
    
    private func loadSampleTrainings() {
        let calendar = Calendar.current
        let now = Date()
        
        // Тренировка на сегодня (если время еще не прошло)
        if let todayStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now),
           todayStart > now {
            let todayEnd = calendar.date(byAdding: .minute, value: 90, to: todayStart)!
            let todayTraining = Training(
                title: "Вечерняя кардио",
                description: "Беговая дорожка и эллипс",
                exerciseCount: 3,
                duration: 90,
                startTime: todayStart,
                endTime: todayEnd,
                notes: "Взять наушники",
                trainer: "Мария Сидорова"
            )
            trainings.append(todayTraining)
        }
        
        // Тренировка на завтра
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
            let tomorrowStart = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: tomorrow)!
            let tomorrowEnd = calendar.date(byAdding: .minute, value: 60, to: tomorrowStart)!
            let tomorrowTraining = Training(
                title: "Грудь и трицепс",
                description: "Силовая тренировка",
                exerciseCount: 8,
                duration: 60,
                startTime: tomorrowStart,
                endTime: tomorrowEnd,
                notes: "Рабочие веса: жим 80кг",
                trainer: "Иван Петров"
            )
            trainings.append(tomorrowTraining)
        }
        
        sortTrainings()
    }
}

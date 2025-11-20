import Foundation
import Combine

class TrainingManager: ObservableObject {
    @Published var trainings: [Training] = []
    
    // Следующая тренировка (самая ближайшая будущая)
    var nextTraining: Training? {
        let futureTrainings = trainings
            .filter { $0.isFuture }
            .sorted { $0.startTime < $1.startTime }
        
        return futureTrainings.first
    }
    
    init() {
        // Добавим примерные тренировки для демонстрации
        loadSampleTrainings()
    }
    
    func addTraining(_ training: Training) {
        trainings.append(training)
        trainings.sort { $0.startTime < $1.startTime }
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
            trainings.sort { $0.startTime < $1.startTime }
        }
    }
    
    func deleteTraining(_ training: Training) {
        trainings.removeAll { $0.id == training.id }
    }
    
    func getTrainings(for date: Date) -> [Training] {
        let calendar = Calendar.current
        return trainings.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func loadSampleTrainings() {
        let calendar = Calendar.current
        
        // Тренировка на сегодня (если время еще не прошло)
        if let todayStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()),
           todayStart > Date() {
            let todayEnd = calendar.date(byAdding: .minute, value: 90, to: todayStart)!
            let todayTraining = Training(
                title: "Вечерняя кардио",
                description: "Беговая дорожка и эллипс",
                exerciseCount: 3,
                duration: 90,
                startTime: todayStart,
                endTime: todayEnd,
                notes: "Взять наушники",
                trainer: "Мария Сидорова",
                date: Date()
            )
            trainings.append(todayTraining)
        }
        
        // Тренировка на завтра
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
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
                trainer: "Иван Петров",
                date: tomorrow
            )
            trainings.append(tomorrowTraining)
        }
        
        // Тренировка через 2 дня
        if let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) {
            let dayAfterStart = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: dayAfterTomorrow)!
            let dayAfterEnd = calendar.date(byAdding: .minute, value: 75, to: dayAfterStart)!
            let dayAfterTraining = Training(
                title: "Спина и бицепс",
                description: "Тяжелые тяги",
                exerciseCount: 6,
                duration: 75,
                startTime: dayAfterStart,
                endTime: dayAfterEnd,
                notes: "Сосредоточиться на технике",
                trainer: "Алексей Козлов",
                date: dayAfterTomorrow
            )
            trainings.append(dayAfterTraining)
        }
        
        trainings.sort { $0.startTime < $1.startTime }
    }
}

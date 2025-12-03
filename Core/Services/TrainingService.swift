import Foundation
import Combine

@MainActor
class TrainingService: ObservableObject {
    @Published var trainings: [Training] = []
    
    init() {
        loadSampleTrainings()
    }
    
    func addTraining(_ training: Training) {
        trainings.append(training)
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
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
        let now = Date()
        
        // Простые тренировки без сложной логики
        let training1 = Training(
            id: "1",
            title: "Вечерняя кардио",
            date: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now,
            type: .cardio
        )
        
        let training2 = Training(
            id: "2",
            title: "Грудь и трицепс",
            date: calendar.date(byAdding: .day, value: 1, to: now) ?? now,
            type: .strength
        )
        
        trainings = [training1, training2]
    }
}

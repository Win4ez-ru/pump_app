// TrainingViewModel.swift
import Foundation
import Combine

@MainActor
class TrainingViewModel: ObservableObject {
    @Published var trainings: [Training] = []
    
    // Используем общий сервис
    private let trainingService = TrainingService.shared
    
    init() {
        loadTrainings()
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Слушаем обновления из сервиса
        NotificationCenter.default.addObserver(
            forName: .trainingsUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadTrainings()
        }
    }
    
    // Загружаем из сервиса
    func loadTrainings() {
        trainings = trainingService.trainings
        print("📊 Во ViewModel загружено: \(trainings.count) тренировок")
    }
    
    // MARK: - Публичные методы
    
    func saveTraining(_ training: Training) {
        trainingService.updateTraining(training)
        // Данные автоматически обновятся через Notification
    }
    
    func deleteTraining(_ training: Training) {
        trainingService.deleteTraining(training)
        // Данные автоматически обновятся через Notification
    }
    
    func trainingsForDate(_ date: Date) -> [Training] {
        trainingService.getTrainings(for: date)
    }
    
    func getNextTraining() -> Training? {
        trainingService.getNextTraining()
    }
    
    // Очистка
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

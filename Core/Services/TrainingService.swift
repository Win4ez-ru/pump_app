// TrainingService.swift
import Foundation
import Combine

@MainActor
class TrainingService: ObservableObject {
    @Published var trainings: [Training] = []
    private let persistence = DataPersistence.shared
    
    static let shared = TrainingService()
        
    // ИСПРАВЛЕНИЕ: Делаем инициализатор public
    public init() {  // <-- Добавляем public
        loadTrainings()
    }
    
    // Загружаем из хранилища
    func loadTrainings() {
        trainings = persistence.loadAllTrainings()
        print("🔄 Загружено в сервис: \(trainings.count) тренировок")
    }
    
    // Сохраняем текущее состояние в хранилище
    private func saveToPersistence() {
        persistence.saveAllTrainings(trainings)
        print("💾 Сохранено в хранилище: \(trainings.count) тренировок")
        
        // Уведомляем о изменениях (для виджета/карточки)
        NotificationCenter.default.post(name: .trainingsUpdated, object: nil)
    }
    
    // MARK: - Основные операции
    
    func addTraining(_ training: Training) {
        // Проверяем, нет ли уже такой тренировки
        guard !trainings.contains(where: { $0.id == training.id }) else {
            print("⚠️ Тренировка с ID \(training.id) уже существует")
            return
        }
        
        trainings.append(training)
        saveToPersistence()
        print("➕ Добавлена тренировка: \(training.title)")
    }
    
    func updateTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
            saveToPersistence()
            print("✏️ Обновлена тренировка: \(training.title)")
        } else {
            print("⚠️ Тренировка для обновления не найдена, добавляем новую")
            addTraining(training)
        }
    }
    
    func deleteTraining(_ training: Training) {
        let beforeCount = trainings.count
        trainings.removeAll { $0.id == training.id }
        
        if trainings.count < beforeCount {
            saveToPersistence()
            print("🗑️ Удалена тренировка: \(training.title)")
        } else {
            print("⚠️ Тренировка для удаления не найдена")
        }
    }
    
    func deleteTraining(byId id: String) {
        if let training = trainings.first(where: { $0.id == id }) {
            deleteTraining(training)
        }
    }
    
    func getTrainings(for date: Date) -> [Training] {
        let calendar = Calendar.current
        return trainings.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getNextTraining() -> Training? {
        let futureTrainings = trainings.filter { $0.date > Date() }
        return futureTrainings.sorted { $0.date < $1.date }.first
    }
}

// Уведомление для синхронизации
extension Notification.Name {
    static let trainingsUpdated = Notification.Name("trainingsUpdated")
}

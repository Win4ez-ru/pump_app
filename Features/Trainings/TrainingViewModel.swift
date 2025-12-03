// Features/Trainings/TrainingViewModel.swift
import Foundation
import Combine

@MainActor
class TrainingViewModel: ObservableObject {
    @Published var trainings: [Training] = []
    @Published var selectedDate = Date()
    @Published var showingEditView = false
    @Published var editingTraining: Training?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let trainingService: TrainingService
    
    init(trainingService: TrainingService) {
        self.trainingService = trainingService
        loadTrainings()
    }
    
    // MARK: - Public Methods
    func loadTrainings() {
        isLoading = true
        errorMessage = nil
        
        // Здесь будет реальная загрузка из TrainingService
        // Пока используем mock данные
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            Task { @MainActor in
                self?.trainings = [
                    Training(
                        id: "1",
                        title: "Силовая тренировка",
                        date: Date(),
                        type: .strength
                    ),
                    Training(
                        id: "2",
                        title: "Кардио сессия",
                        date: Date().addingTimeInterval(86400),
                        type: .cardio
                    )
                ]
                self?.isLoading = false
            }
        }
    }
    
    func saveTraining(_ training: Training) {
        if let index = trainings.firstIndex(where: { $0.id == training.id }) {
            trainings[index] = training
        } else {
            trainings.append(training)
        }
        
        // Здесь будет вызов trainingService.saveTraining(training)
        Helpers.hapticFeedback()
    }
    
    func deleteTraining(_ training: Training) {
        trainings.removeAll { $0.id == training.id }
        // Здесь будет вызов trainingService.deleteTraining(training)
        Helpers.hapticFeedback()
    }
    
    func trainingsForDate(_ date: Date) -> [Training] {
        trainings.filter { $0.date.isSameDay(as: date) }
    }
    
    func startEditing(_ training: Training?) {
        editingTraining = training
        showingEditView = true
    }
}

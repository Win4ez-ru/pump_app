import Foundation

class DataPersistence {
    static let shared = DataPersistence()
    
    private let trainingsKey = "saved_trainings_v3" // Новый ключ для чистого старта
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func saveAllTrainings(_ trainings: [Training]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(trainings)
            defaults.set(data, forKey: trainingsKey)
            print("💾 Сохранено тренировок: \(trainings.count)")
        } catch {
            print("❌ Ошибка сохранения: \(error)")
        }
    }
    
    func loadAllTrainings() -> [Training] {
        guard let data = defaults.data(forKey: trainingsKey) else {
            print("📭 Нет сохранённых данных")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let trainings = try decoder.decode([Training].self, from: data)
            print("📥 Загружено тренировок: \(trainings.count)")
            return trainings
        } catch {
            print("❌ Ошибка загрузки: \(error)")
            return []
        }
    }
}

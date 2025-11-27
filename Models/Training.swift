import Foundation

struct Training: Identifiable, Codable, Comparable {
    let id: UUID
    var title: String
    var description: String
    var exerciseCount: Int
    var duration: Int
    var startTime: Date
    var endTime: Date
    var notes: String
    var trainer: String
    var date: Date {
        Calendar.current.startOfDay(for: startTime)
    }
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         exerciseCount: Int,
         duration: Int,
         startTime: Date,
         endTime: Date,
         notes: String,
         trainer: String) {
        self.id = id
        self.title = title
        self.description = description
        self.exerciseCount = exerciseCount
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.trainer = trainer
    }
    
    // Для сравнения тренировок по дате
    static func < (lhs: Training, rhs: Training) -> Bool {
        return lhs.startTime < rhs.startTime
    }
    
    static func == (lhs: Training, rhs: Training) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Проверка, является ли тренировка будущей
    var isFuture: Bool {
        return startTime > Date()
    }
    
    static var sample: Training {
        let startTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
        let endTime = Calendar.current.date(byAdding: .minute, value: 60, to: startTime)!
        
        return Training(
            title: "Грудь и трицепс",
            description: "Силовая тренировка на верх тела",
            exerciseCount: 8,
            duration: 60,
            startTime: startTime,
            endTime: endTime,
            notes: "Не забыть взять полотенце",
            trainer: "Иван Петров"
        )
    }
}

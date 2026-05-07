import Foundation

struct ClientFitnessProfile: Codable, Equatable {
    var displayName: String
    var about: String
    var age: Int
    var gender: ClientGender
    var height: Int
    var weight: Int
    var goal: FitnessGoal
    var trainingPlace: TrainingPlace
    var trainingExperience: ClientTrainingExperience
    var preferredTrainerGender: TrainerGender
    var weeklyTrainingGoal: Int

    static let demo = ClientFitnessProfile(
        displayName: "Гость",
        about: "Хочу тренироваться регулярно и видеть понятный прогресс без перегруза.",
        age: 28,
        gender: .notSpecified,
        height: 175,
        weight: 72,
        goal: .loseWeight,
        trainingPlace: .online,
        trainingExperience: .beginner,
        preferredTrainerGender: .any,
        weeklyTrainingGoal: 3
    )
}

enum ClientGender: String, CaseIterable, Codable, Identifiable {
    case female = "Женщина"
    case male = "Мужчина"
    case notSpecified = "Не указано"

    var id: String { rawValue }
    var title: String { rawValue }
}

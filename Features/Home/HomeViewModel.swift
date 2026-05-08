// Features/Home/HomeViewModel.swift
import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var currentTrainerIndex = 0
    @Published var selectedFilters: Set<TrainerFilter> = []
    @Published var selectedGoal: FitnessGoal = .loseWeight
    @Published var selectedPlace: TrainingPlace = .online
    @Published var selectedExperience: ClientTrainingExperience = .beginner
    @Published var selectedTrainerGender: TrainerGender = .any
    @Published var preferredMinAge = 24
    @Published var preferredMaxAge = 45
    @Published var minTrainerExperience = 0
    @Published var trainerRequests: [TrainerRequest] = []
    @Published var skippedTrainerIDs: Set<String> = []
    @Published var isLoading = false

    private var timer: Timer?

    let quickFilters: [TrainerFilter] = [
        TrainerFilter(id: "strength", name: "Силовые"),
        TrainerFilter(id: "yoga", name: "Йога"),
        TrainerFilter(id: "cardio", name: "Кардио"),
        TrainerFilter(id: "crossfit", name: "Кроссфит"),
        TrainerFilter(id: "beginners", name: "Для начинающих"),
        TrainerFilter(id: "recovery", name: "Реабилитация"),
        TrainerFilter(id: "weightloss", name: "Похудение"),
        TrainerFilter(id: "online", name: "Онлайн")
    ]

    let recommendedTrainers: [Trainer] = [
        Trainer(
            id: "1",
            name: "Алексей Иванов",
            specialization: "Силовые тренировки",
            description: "Собираю понятный план под зал и домашние тренировки, слежу за техникой и прогрессом по силовым.",
            rating: 4.9,
            reviewCount: 128,
            experienceYears: 8,
            price: "1500",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_1_1", "trainer_1_2", "trainer_1_3"],
            isOnline: true,
            specializationTags: ["Силовые", "Набор массы", "Для начинающих"],
            location: "Москва, ЦАО",
            availableForOnline: true,
            gender: .male,
            age: 34,
            achievements: ["КМС по пауэрлифтингу", "120+ клиентов"],
            formats: [.gym, .home, .online],
            bestForGoals: [.gainMuscle, .getStronger, .habit],
            bestForExperience: [.beginner, .regular],
            responseTime: "обычно отвечает за 15 минут"
        ),
        Trainer(
            id: "2",
            name: "Мария Петрова",
            specialization: "Йога и растяжка",
            description: "Помогаю снять напряжение, улучшить мобильность и мягко встроить регулярную активность в неделю.",
            rating: 4.8,
            reviewCount: 94,
            experienceYears: 6,
            price: "1200",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_2_1", "trainer_2_2", "trainer_2_3"],
            isOnline: true,
            specializationTags: ["Йога", "Растяжка", "Восстановление"],
            location: "Онлайн",
            availableForOnline: true,
            gender: .female,
            age: 29,
            achievements: ["Yoga Alliance RYT 500", "Автор мягких стартов"],
            formats: [.home, .outside, .online],
            bestForGoals: [.mobility, .recovery, .habit],
            bestForExperience: [.firstTime, .beginner, .regular],
            responseTime: "обычно отвечает за 1 час"
        ),
        Trainer(
            id: "3",
            name: "Дмитрий Смирнов",
            specialization: "Кроссфит",
            description: "Функциональная подготовка, выносливость и работа с соревновательными целями без хаоса в нагрузке.",
            rating: 4.7,
            reviewCount: 156,
            experienceYears: 10,
            price: "2000",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_3_1", "trainer_3_2", "trainer_3_3"],
            isOnline: false,
            specializationTags: ["Кроссфит", "Выносливость", "Силовые"],
            location: "Москва, СВАО",
            availableForOnline: false,
            gender: .male,
            age: 38,
            achievements: ["Участник региональных стартов", "10 лет практики"],
            formats: [.gym, .outside],
            bestForGoals: [.endurance, .getStronger, .gainMuscle],
            bestForExperience: [.regular, .advanced],
            responseTime: "отвечает в течение дня"
        ),
        Trainer(
            id: "4",
            name: "Ольга Козлова",
            specialization: "Пилатес и реабилитация",
            description: "Аккуратно работаю с осанкой, позвоночником и возвращением к тренировкам после перерыва.",
            rating: 4.9,
            reviewCount: 87,
            experienceYears: 7,
            price: "1300",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_4_1", "trainer_4_2", "trainer_4_3"],
            isOnline: true,
            specializationTags: ["Пилатес", "Реабилитация", "Для начинающих"],
            location: "Москва, ЮАО",
            availableForOnline: true,
            gender: .female,
            age: 33,
            achievements: ["Сертификат Pilates Mat", "Специализация по спине"],
            formats: [.home, .online],
            bestForGoals: [.recovery, .mobility, .loseWeight],
            bestForExperience: [.firstTime, .beginner],
            responseTime: "обычно отвечает за 30 минут"
        ),
        Trainer(
            id: "5",
            name: "Иван Соколов",
            specialization: "Бокс и единоборства",
            description: "Ставлю базовую технику, координацию и уверенность. Подходит для энергии, дисциплины и формы.",
            rating: 4.6,
            reviewCount: 112,
            experienceYears: 9,
            price: "1800",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_5_1", "trainer_5_2", "trainer_5_3"],
            isOnline: false,
            specializationTags: ["Бокс", "Кардио", "Выносливость"],
            location: "Москва, ЗАО",
            availableForOnline: false,
            gender: .male,
            age: 36,
            achievements: ["КМС по боксу", "Детские и взрослые группы"],
            formats: [.gym, .outside],
            bestForGoals: [.endurance, .loseWeight, .habit],
            bestForExperience: [.beginner, .regular],
            responseTime: "обычно отвечает вечером"
        ),
        Trainer(
            id: "6",
            name: "Ника Морозова",
            specialization: "Похудение и питание",
            description: "Соединяю тренировки, шаги и простое КБЖУ. Без жестких диет, с видимым прогрессом каждую неделю.",
            rating: 5.0,
            reviewCount: 73,
            experienceYears: 5,
            price: "1600",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            photoNames: ["trainer_6_1", "trainer_6_2", "trainer_6_3"],
            isOnline: true,
            specializationTags: ["Похудение", "КБЖУ", "Онлайн"],
            location: "Онлайн",
            availableForOnline: true,
            gender: .female,
            age: 27,
            achievements: ["Нутрициолог", "Минус 900 кг у клиентов"],
            formats: [.home, .gym, .online],
            bestForGoals: [.loseWeight, .habit, .mobility],
            bestForExperience: [.firstTime, .beginner, .regular],
            responseTime: "обычно отвечает за 10 минут"
        )
    ]

    var filteredTrainers: [Trainer] {
        let trainers = recommendedTrainers.filter { trainer in
            let matchesSearch = searchText.isEmpty ||
                trainer.name.localizedCaseInsensitiveContains(searchText) ||
                trainer.specialization.localizedCaseInsensitiveContains(searchText) ||
                trainer.description.localizedCaseInsensitiveContains(searchText) ||
                trainer.specializationTags.contains { $0.localizedCaseInsensitiveContains(searchText) }

            let matchesFilters = selectedFilters.isEmpty ||
                selectedFilters.allSatisfy { filter in
                    trainer.specializationTags.contains(filter.name) ||
                    (filter.id == "online" && trainer.availableForOnline)
                }

            let matchesGender = selectedTrainerGender == .any || trainer.gender == selectedTrainerGender
            let matchesAge = trainer.age >= preferredMinAge && trainer.age <= preferredMaxAge
            let matchesExperience = trainer.experienceYears >= minTrainerExperience
            let matchesPlace = trainer.formats.contains(selectedPlace)
            let isNotSkipped = !skippedTrainerIDs.contains(trainer.id)

            return matchesSearch && matchesFilters && matchesGender && matchesAge && matchesExperience && matchesPlace && isNotSkipped
        }

        return trainers.sorted { matchScore(for: $0) > matchScore(for: $1) }
    }

    var currentTrainer: Trainer? {
        guard !filteredTrainers.isEmpty else { return nil }
        return filteredTrainers[currentTrainerIndex % filteredTrainers.count]
    }

    var sentRequests: Set<String> {
        Set(trainerRequests.map(\.trainerID))
    }

    var pendingRequestsCount: Int {
        trainerRequests.filter { $0.status == .pending }.count
    }

    var acceptedRequestsCount: Int {
        trainerRequests.filter { $0.status == .accepted }.count
    }

    var sentRequestItems: [(request: TrainerRequest, trainer: Trainer)] {
        trainerRequests.compactMap { request in
            guard let trainer = recommendedTrainers.first(where: { $0.id == request.trainerID }) else {
                return nil
            }

            return (request, trainer)
        }
        .sorted { $0.request.createdAt > $1.request.createdAt }
    }

    var activeMatchSummary: String {
        "\(selectedGoal.title.lowercased()), \(selectedPlace.title.lowercased()), \(selectedExperience.title.lowercased())"
    }

    func matchScore(for trainer: Trainer) -> Int {
        var score = 58

        if trainer.bestForGoals.contains(selectedGoal) { score += 18 }
        if trainer.formats.contains(selectedPlace) { score += 10 }
        if trainer.bestForExperience.contains(selectedExperience) { score += 10 }
        if selectedTrainerGender != .any && trainer.gender == selectedTrainerGender { score += 4 }
        if trainer.availableForOnline && selectedPlace == .online { score += 4 }
        if trainer.rating >= 4.8 { score += 3 }

        return min(score, 99)
    }

    func startAutoScroll() {
        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: 18.0, repeats: true) { [weak self] _ in
            self?.nextTrainer()
        }
    }

    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }

    func nextTrainer() {
        guard !filteredTrainers.isEmpty else { return }
        currentTrainerIndex = (currentTrainerIndex + 1) % filteredTrainers.count
    }

    func skipCurrentTrainer() {
        guard let trainer = currentTrainer else { return }
        skippedTrainerIDs.insert(trainer.id)
        normalizeCurrentIndex()
    }

    func sendRequest(to trainer: Trainer) {
        guard !sentRequests.contains(trainer.id) else {
            nextTrainer()
            return
        }

        let request = TrainerRequest(
            id: UUID().uuidString,
            trainerID: trainer.id,
            status: .pending,
            createdAt: Date(),
            goal: selectedGoal,
            place: selectedPlace,
            experience: selectedExperience,
            message: "Хочу обсудить тренировки: \(activeMatchSummary)."
        )

        trainerRequests.append(request)
        nextTrainer()
    }

    func toggleFilter(_ filter: TrainerFilter) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
        normalizeCurrentIndex()
    }

    func resetFilters() {
        selectedFilters.removeAll()
        searchText = ""
        selectedTrainerGender = .any
        preferredMinAge = 24
        preferredMaxAge = 45
        minTrainerExperience = 0
        skippedTrainerIDs.removeAll()
        normalizeCurrentIndex()
    }

    func applyQuiz(goal: FitnessGoal, place: TrainingPlace, experience: ClientTrainingExperience, gender: TrainerGender) {
        selectedGoal = goal
        selectedPlace = place
        selectedExperience = experience
        selectedTrainerGender = gender
        skippedTrainerIDs.removeAll()
        normalizeCurrentIndex()
    }

    func applyFitnessProfile(_ profile: ClientFitnessProfile) {
        selectedGoal = profile.goal
        selectedPlace = profile.trainingPlace
        selectedExperience = profile.trainingExperience
        selectedTrainerGender = profile.preferredTrainerGender
        normalizeCurrentIndex()
    }

    func loadData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }

    private func normalizeCurrentIndex() {
        if filteredTrainers.isEmpty {
            currentTrainerIndex = 0
        } else {
            currentTrainerIndex = min(currentTrainerIndex, filteredTrainers.count - 1)
        }
    }

    deinit {
        stopAutoScroll()
    }
}

struct TrainerRequest: Identifiable, Equatable {
    let id: String
    let trainerID: String
    var status: TrainerRequestStatus
    let createdAt: Date
    let goal: FitnessGoal
    let place: TrainingPlace
    let experience: ClientTrainingExperience
    let message: String
}

enum TrainerRequestStatus: String, CaseIterable, Identifiable {
    case pending = "Ожидает"
    case accepted = "Принят"
    case declined = "Отклонен"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle.fill"
        }
    }
}

struct Trainer: Identifiable, Equatable {
    let id: String
    let name: String
    let specialization: String
    let description: String
    let rating: Double
    let reviewCount: Int
    let experienceYears: Int
    let price: String
    let priceUnit: String
    let imageName: String
    let photoNames: [String]
    let isOnline: Bool
    let specializationTags: [String]
    let location: String
    let availableForOnline: Bool
    let gender: TrainerGender
    let age: Int
    let achievements: [String]
    let formats: [TrainingPlace]
    let bestForGoals: [FitnessGoal]
    let bestForExperience: [ClientTrainingExperience]
    let responseTime: String

    var experience: String {
        "\(experienceYears) \(Self.yearWord(experienceYears))"
    }

    private static func yearWord(_ value: Int) -> String {
        let last = value % 10
        let lastTwo = value % 100

        if lastTwo >= 11 && lastTwo <= 14 { return "лет" }
        if last == 1 { return "год" }
        if last >= 2 && last <= 4 { return "года" }
        return "лет"
    }
}

struct TrainerFilter: Identifiable, Hashable {
    let id: String
    let name: String
}

enum TrainerGender: String, CaseIterable, Codable, Identifiable {
    case any = "Любой"
    case female = "Женщина"
    case male = "Мужчина"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum FitnessGoal: String, CaseIterable, Codable, Identifiable {
    case loseWeight = "Похудение"
    case gainMuscle = "Набор массы"
    case getStronger = "Сила"
    case endurance = "Выносливость"
    case mobility = "Гибкость"
    case recovery = "Восстановление"
    case habit = "Привычка"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum TrainingPlace: String, CaseIterable, Codable, Identifiable {
    case online = "Онлайн"
    case home = "Дома"
    case gym = "В зале"
    case outside = "На улице"

    var id: String { rawValue }
    var title: String { rawValue }
}

enum ClientTrainingExperience: String, CaseIterable, Codable, Identifiable {
    case firstTime = "С нуля"
    case beginner = "Начинающий"
    case regular = "Тренируюсь"
    case advanced = "Опытный"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct NextWorkoutCardData {
    let title: String
    let time: String
    let type: String
    let trainerName: String?
    let isUpcoming: Bool
}

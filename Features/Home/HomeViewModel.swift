// Features/Home/HomeViewModel.swift
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var currentTrainerIndex = 0
    @Published var selectedFilters: Set<TrainerFilter> = []
    @Published var isLoading = false
    
    private var timer: Timer?
    
    // Фильтры для быстрого поиска
    let quickFilters: [TrainerFilter] = [
        TrainerFilter(id: "strength", name: "🏋️ Силовые"),
        TrainerFilter(id: "yoga", name: "🧘 Йога"),
        TrainerFilter(id: "cardio", name: "🏃 Кардио"),
        TrainerFilter(id: "crossfit", name: "💪 Кроссфит"),
        TrainerFilter(id: "beginners", name: "👶 Для начинающих"),
        TrainerFilter(id: "recovery", name: "🩹 Реабилитация"),
        TrainerFilter(id: "weightloss", name: "⚖️ Похудение"),
        TrainerFilter(id: "online", name: "💻 Онлайн")
    ]
    
    // Рекомендуемые тренеры (в реальном приложении будет загрузка из API)
    let recommendedTrainers: [Trainer] = [
        Trainer(
            id: "1",
            name: "Алексей Иванов",
            specialization: "Силовые тренировки",
            description: "Сертифицированный тренер по бодибилдингу. Помогу набрать мышечную массу и увеличить силовые показатели.",
            rating: 4.9,
            reviewCount: 128,
            experience: "8 лет",
            price: "1500",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            isOnline: true,
            specializationTags: ["🏋️ Силовые", "💪 Набор массы"],
            location: "Москва, ЦАО",
            availableForOnline: true
        ),
        Trainer(
            id: "2",
            name: "Мария Петрова",
            specialization: "Йога и растяжка",
            description: "Инструктор по хатха йоге и стретчингу. Работаю над гибкостью, осанкой и ментальным здоровьем.",
            rating: 4.8,
            reviewCount: 94,
            experience: "6 лет",
            price: "1200",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            isOnline: true,
            specializationTags: ["🧘 Йога", "🤸 Растяжка"],
            location: "Онлайн",
            availableForOnline: true
        ),
        Trainer(
            id: "3",
            name: "Дмитрий Смирнов",
            specialization: "Кроссфит",
            description: "Тренер по функциональному тренингу. Подготовлю к соревнованиям или помогу стать выносливее.",
            rating: 4.7,
            reviewCount: 156,
            experience: "10 лет",
            price: "2000",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            isOnline: false,
            specializationTags: ["💪 Кроссфит", "🏃 Выносливость"],
            location: "Москва, СВАО",
            availableForOnline: false
        ),
        Trainer(
            id: "4",
            name: "Ольга Козлова",
            specialization: "Пилатес",
            description: "Сертифицированный тренер по пилатесу. Специализируюсь на реабилитации и работе с позвоночником.",
            rating: 4.9,
            reviewCount: 87,
            experience: "7 лет",
            price: "1300",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            isOnline: true,
            specializationTags: ["🧘 Пилатес", "🩹 Реабилитация"],
            location: "Москва, ЮАО",
            availableForOnline: true
        ),
        Trainer(
            id: "5",
            name: "Иван Соколов",
            specialization: "Бокс и единоборства",
            description: "Тренер по боксу и самообороне. Научу технике ударов и работе в паре.",
            rating: 4.6,
            reviewCount: 112,
            experience: "9 лет",
            price: "1800",
            priceUnit: "₽/сессия",
            imageName: "person.crop.circle.fill",
            isOnline: false,
            specializationTags: ["🥊 Бокс", "⚔️ Единоборства"],
            location: "Москва, ЗАО",
            availableForOnline: false
        )
    ]
    
    // Отфильтрованные тренеры
    var filteredTrainers: [Trainer] {
        if searchText.isEmpty && selectedFilters.isEmpty {
            return recommendedTrainers
        }
        
        return recommendedTrainers.filter { trainer in
            let matchesSearch = searchText.isEmpty ||
                trainer.name.localizedCaseInsensitiveContains(searchText) ||
                trainer.specialization.localizedCaseInsensitiveContains(searchText) ||
                trainer.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilters = selectedFilters.isEmpty ||
                selectedFilters.allSatisfy { filter in
                    trainer.specializationTags.contains(filter.name) ||
                    (filter.id == "online" && trainer.availableForOnline)
                }
            
            return matchesSearch && matchesFilters
        }
    }
    
    // Текущий тренер для карусели
    var currentTrainer: Trainer? {
        guard !filteredTrainers.isEmpty else { return nil }
        return filteredTrainers[currentTrainerIndex % filteredTrainers.count]
    }
    
    func startAutoScroll() {
            stopAutoScroll()
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
                guard let self = self, !self.filteredTrainers.isEmpty else { return }
                
                // УБЕРИТЕ withAnimation отсюда:
                self.currentTrainerIndex += 1  // ✅ Просто меняем значение без анимации
            }
        }
        
    // Остановка автопрокрутки
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
        
    // HomeViewModel.swift - обновленные методы для свайпа
    func nextTrainer() {
        guard !filteredTrainers.isEmpty else { return }
        
        // Просто увеличиваем индекс - анимация будет в View
        currentTrainerIndex += 1
    }

    func previousTrainer() {
        guard !filteredTrainers.isEmpty else { return }
        
        // Просто уменьшаем индекс - анимация будет в View
        currentTrainerIndex = currentTrainerIndex > 0 ? currentTrainerIndex - 1 : filteredTrainers.count - 1
    }
    
    // Переключение фильтра
    func toggleFilter(_ filter: TrainerFilter) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    // Сброс всех фильтров
    func resetFilters() {
        selectedFilters.removeAll()
        searchText = ""
    }
    
    // Загрузка данных (заглушка для будущей реализации)
    func loadData() {
        isLoading = true
        // Здесь будет загрузка из API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    deinit {
        stopAutoScroll()
    }
}

// MARK: - Модели данных

struct Trainer: Identifiable, Equatable {
    let id: String
    let name: String
    let specialization: String
    let description: String
    let rating: Double
    let reviewCount: Int
    let experience: String
    let price: String
    let priceUnit: String
    let imageName: String
    let isOnline: Bool
    let specializationTags: [String]
    let location: String
    let availableForOnline: Bool
    
    static func == (lhs: Trainer, rhs: Trainer) -> Bool {
        lhs.id == rhs.id
    }
}

struct TrainerFilter: Identifiable, Hashable {
    let id: String
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TrainerFilter, rhs: TrainerFilter) -> Bool {
        lhs.id == rhs.id
    }
}

struct NextWorkoutCardData {
    let title: String
    let time: String
    let type: String
    let trainerName: String?
    let isUpcoming: Bool
}


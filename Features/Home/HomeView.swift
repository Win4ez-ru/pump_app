// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var trainingViewModel: TrainingViewModel
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var showingAdvancedSearch = false
    @State private var showingTrainerDetail: Trainer?
    
    var nextWorkout: Training? {
        let futureTrainings = trainingViewModel.trainings.filter { $0.date > Date() }
        return futureTrainings.sorted { $0.date < $1.date }.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Приветствие
                greetingView
                
                // Карточка следующей тренировки
                if let workout = nextWorkout {
                    HomeNextWorkoutCard(
                        workout: workout,
                        onTap: {
                            // Навигация к деталям тренировки
                            print("Переход к тренировке")
                        }
                    )
                }
                
                // Блок поиска тренера
                trainerSearchCard
                
                // Рекомендуемые тренеры
                recommendedTrainersSection
                
                // Рекламный баннер (вместо кнопки "Подробнее о тренере")
                PromoBannerView()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Главная")
        .sheet(isPresented: $showingAdvancedSearch) {
            AdvancedSearchView(viewModel: viewModel)
        }
        .sheet(item: $showingTrainerDetail) { trainer in
            TrainerDetailView(trainer: trainer)
        }
        .onAppear {
            trainingViewModel.loadTrainings()
            viewModel.startAutoScroll()
        }
        .onDisappear {
            viewModel.stopAutoScroll()
        }
        .refreshable {
            viewModel.loadData()
            trainingViewModel.loadTrainings()
        }
    }
    
    // MARK: - Приветствие
    
    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(getGreeting())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Найдите идеального тренера для ваших целей")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Поиск тренера
    
    private var trainerSearchCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Найдите своего тренера")
                        .font(.headline)
                    
                    Text("Персональный подбор по вашим критериям")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingAdvancedSearch = true
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Рекомендуемые тренеры (карусель со свайпом)

    private var recommendedTrainersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Рекомендуем")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("\(viewModel.currentTrainerIndex % max(viewModel.filteredTrainers.count, 1) + 1)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text("/\(viewModel.filteredTrainers.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, -50)
            
            if viewModel.filteredTrainers.isEmpty {
                // Состояние пустого поиска
                EmptyTrainersView(viewModel: viewModel)
            } else {
                // Карточка тренера с свайпом
                ZStack {
                    ForEach(viewModel.filteredTrainers.indices, id: \.self) { index in
                        let trainer = viewModel.filteredTrainers[index]
                        let isCurrent = index == viewModel.currentTrainerIndex % viewModel.filteredTrainers.count
                        
                        if isCurrent {
                            TrainerCard(trainer: trainer)
                                .padding(.horizontal)
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            withAnimation(.spring(response: 0.3)) {
                                                if value.translation.width < -50 {
                                                    // Свайп влево - следующий тренер
                                                    viewModel.nextTrainer()
                                                } else if value.translation.width > 50 {
                                                    // Свайп вправо - предыдущий тренер
                                                    viewModel.previousTrainer()
                                                }
                                            }
                                        }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                ))
                        }
                    }
                }
                .frame(height: 280)
                
                // Индикаторы прогресса (точки)
                HStack(spacing: 8) {
                    ForEach(0..<min(viewModel.filteredTrainers.count, 5), id: \.self) { index in
                        let adjustedIndex = viewModel.currentTrainerIndex % viewModel.filteredTrainers.count
                        let isActive = index == adjustedIndex % 5
                        
                        Circle()
                            .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isActive ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: isActive)
                    }
                }
                .frame(maxWidth: .infinity) // ← Это центрирует по горизонтали
                .padding(.top, -20) // ← Чуть ниже карточки (можно изменить на 10, 15 и т.д.)
            }
        }
    }
    
    // MARK: - Рекламный баннер

    struct PromoBannerView: View {
        @State private var timeRemaining = 3600 // 1 час в секундах
        @State private var timer: Timer?
        
        var body: some View {
            Button(action: {
                print("Нажата рекламная акция")
            }) {
                HStack(spacing: 12) {
                    // Левая часть: Иконка и текст
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("АКЦИЯ")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Пробная тренировка")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("со скидкой 50%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Успеете!")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    // Правая часть: Таймер и кнопка
                    VStack(alignment: .trailing, spacing: 8) {
                        // Таймер
                        VStack(spacing: 2) {
                            Text("До конца акции")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 2) {
                                TimeUnitView(value: timeRemaining / 3600, label: "ч")
                                Text(":")
                                    .foregroundColor(.white)
                                TimeUnitView(value: (timeRemaining % 3600) / 60, label: "м")
                                Text(":")
                                    .foregroundColor(.white)
                                TimeUnitView(value: timeRemaining % 60, label: "с")
                            }
                        }
                        
                        // Кнопка
                        HStack {
                            Text("Успеть")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
        
        private func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    stopTimer()
                }
            }
        }
        
        private func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        private func formatTime() -> String {
            let hours = timeRemaining / 3600
            let minutes = (timeRemaining % 3600) / 60
            let seconds = timeRemaining % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    // MARK: - Компонент для отображения времени

    struct TimeUnitView: View {
        let value: Int
        let label: String
        
        var body: some View {
            VStack(spacing: 2) {
                Text(String(format: "%02d", value))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(4)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Пустое состояние для тренеров

    struct EmptyTrainersView: View {
        @ObservedObject var viewModel: HomeViewModel
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "person.2.slash")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                
                Text("Тренеры не найдены")
                    .font(.headline)
                
                Text("Попробуйте изменить критерии поиска")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Сбросить фильтры") {
                    viewModel.resetFilters()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Вспомогательные функции
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        
        switch hour {
        case 5..<12:
            greeting = "Доброе утро"
        case 12..<17:
            greeting = "Добрый день"
        case 17..<22:
            greeting = "Добрый вечер"
        default:
            greeting = "Доброй ночи"
        }
        
        if let user = authService.currentUser {
            return "\(greeting), \(user.displayName)!"
        } else {
            return "\(greeting)!"
        }
    }
}

// MARK: - Компоненты

struct HomeNextWorkoutCard: View {
    let workout: Training
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Следующая тренировка")
                        .font(.headline)
                    
                    Text(workout.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        
                        Text(formatDate(workout.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM, HH:mm"
        return formatter.string(from: date)
    }
}

struct TrainerCard: View {
    let trainer: Trainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с онлайн статусом
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(trainer.name)
                            .font(.headline)
                        
                        if trainer.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(trainer.specialization)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Рейтинг
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", trainer.rating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("(\(trainer.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Описание
            Text(trainer.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Теги специализации
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(trainer.specializationTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Футер с ценой и локацией
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(trainer.price)")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(trainer.priceUnit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text(trainer.location)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Кнопка записи
                Button(action: {
                    print("Запись к \(trainer.name)")
                }) {
                    Text("Записаться")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.blue : Color(.systemGray6)
            )
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Заглушки для доп. экранов

struct AdvancedSearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Расширенный поиск")
                    .font(.title2)
                    .padding()
                Spacer()
            }
            .navigationTitle("Поиск тренера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TrainerDetailView: View {
    let trainer: Trainer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 8) {
                        Text(trainer.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(trainer.specialization)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    // Информация о тренере
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "star.fill", title: "Рейтинг", value: "\(trainer.rating) (\(trainer.reviewCount) отзывов)")
                        DetailRow(icon: "briefcase.fill", title: "Опыт", value: trainer.experience)
                        DetailRow(icon: "location.fill", title: "Локация", value: trainer.location)
                        DetailRow(icon: trainer.availableForOnline ? "checkmark.circle.fill" : "xmark.circle.fill",
                                title: "Онлайн тренировки",
                                value: trainer.availableForOnline ? "Доступны" : "Не доступны")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("О тренере")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(AuthService())
                .environmentObject(TrainingViewModel(trainingService: TrainingService()))
        }
    }
}

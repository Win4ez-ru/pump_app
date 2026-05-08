// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var trainingViewModel: TrainingViewModel

    var onOpenMatching: () -> Void = {}

    var nextWorkout: Training? {
        let futureTrainings = trainingViewModel.trainings.filter { $0.date > Date() }
        return futureTrainings.sorted { $0.date < $1.date }.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                greetingView

                PromoBannerView()
                    .padding(.horizontal, 20)

                if let workout = nextWorkout {
                    HomeNextWorkoutCard(workout: workout) {
                        print("Переход к тренировке")
                    }
                }

                matchSetupCard
                healthInsightStrip
                quickActionsSection
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Главная")
        .onAppear {
            trainingViewModel.loadTrainings()
        }
        .refreshable {
            trainingViewModel.loadTrainings()
        }
    }

    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(getGreeting())
                .font(.title2)
                .fontWeight(.semibold)

            Text("Подберем тренера под цель, формат и ваш темп")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var matchSetupCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(width: 46, height: 46)

                    Image(systemName: "wand.and.stars")
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Умный подбор")
                        .font(.headline)

                    Text("Тест, фильтры и swipe-анкеты тренеров")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: onOpenMatching) {
                    Label("Открыть подбор", systemImage: "sparkles")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button(action: onOpenMatching) {
                    Label("Анкеты", systemImage: "rectangle.stack.person.crop")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private var healthInsightStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                InsightPill(icon: "figure.walk", title: "8 420 шагов", subtitle: "сегодня", color: .green)
                InsightPill(icon: "flame.fill", title: "1 860 ккал", subtitle: "план КБЖУ", color: .orange)
                InsightPill(icon: "chart.line.uptrend.xyaxis", title: "+12%", subtitle: "прогресс", color: .purple)
                InsightPill(icon: "moon.fill", title: "7ч 20м", subtitle: "сон", color: .indigo)
            }
            .padding(.horizontal, 20)
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Что выделит приложение")
                .font(.headline)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FeatureTile(icon: "target", title: "План недели", subtitle: "тренер видит цель и нагрузку", color: .blue)
                FeatureTile(icon: "heart.text.square.fill", title: "Health-сводка", subtitle: "шаги, активность, КБЖУ", color: .red)
                NavigationLink(destination: CareerView()) {
                    FeatureTile(icon: "rosette", title: "Достижения", subtitle: "серии, уровни и бейджи", color: .orange)
                }
                .buttonStyle(PlainButtonStyle())

                FeatureTile(icon: "person.3.sequence.fill", title: "Рейтинг", subtitle: "по прогрессу, не по весу", color: .green)
            }
            .padding(.horizontal, 20)
        }
    }

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

struct PromoBannerView: View {
    @State private var timeRemaining = 3600
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.headline)
                .foregroundColor(.orange)
                .frame(width: 38, height: 38)
                .background(Color(.systemGray6))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("Пробная тренировка")
                    .font(.headline)

                Text("50% скидка на первый матч")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(formatTime())
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Text("Акция")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
        String(format: "%02d:%02d:%02d", timeRemaining / 3600, (timeRemaining % 3600) / 60, timeRemaining % 60)
    }
}

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

                    Label(formatDate(workout.date), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
            )
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

struct TrainerSwipeCard: View {
    let trainer: Trainer
    let matchScore: Int
    let hasSentRequest: Bool
    let dragOffset: CGSize
    let onTap: () -> Void
    let onSkip: () -> Void
    let onRequest: () -> Void
    @State private var selectedPhotoIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TrainerPhotoPager(
                trainer: trainer,
                matchScore: matchScore,
                selectedPhotoIndex: $selectedPhotoIndex,
                onInfo: onTap
            )

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    TrainerStatPill(icon: "star.fill", value: String(format: "%.1f", trainer.rating), title: "\(trainer.reviewCount) отзывов", color: .yellow)
                    TrainerStatPill(icon: "briefcase.fill", value: trainer.experience, title: "стаж", color: .blue)
                    TrainerStatPill(icon: "banknote.fill", value: "\(trainer.price) ₽", title: "сессия", color: .green)
                }

                TrainerDetailsSection(trainer: trainer)

                HStack(spacing: 14) {
                    CircleButton(icon: "xmark", color: .red, action: onSkip)

                    Button(action: onRequest) {
                        Label(hasSentRequest ? "Запрос отправлен" : "Отправить запрос", systemImage: hasSentRequest ? "checkmark" : "heart.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(hasSentRequest ? Color.green : Color.blue)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
        .overlay(alignment: .topLeading) {
            SwipeHint(text: "ПРОПУСТИТЬ", color: .red)
                .opacity(dragOffset.width < -45 ? 1 : 0)
                .padding(22)
                .rotationEffect(.degrees(-12))
        }
        .overlay(alignment: .topTrailing) {
            SwipeHint(text: "ЗАПРОС", color: .green)
                .opacity(dragOffset.width > 45 ? 1 : 0)
                .padding(22)
                .rotationEffect(.degrees(12))
        }
    }
}

struct TrainerPhotoPager: View {
    let trainer: Trainer
    let matchScore: Int
    @Binding var selectedPhotoIndex: Int
    let onInfo: () -> Void

    private var photoCount: Int {
        max(trainer.photoNames.count, 1)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            trainerPhoto
                .frame(height: 500)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.08), .black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            HStack(spacing: 5) {
                ForEach(0..<photoCount, id: \.self) { index in
                    Capsule()
                        .fill(index == selectedPhotoIndex ? Color.white : Color.white.opacity(0.38))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .frame(maxHeight: .infinity, alignment: .top)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPhotoIndex = max(0, selectedPhotoIndex - 1)
                    }

                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPhotoIndex = min(photoCount - 1, selectedPhotoIndex + 1)
                    }
            }

            Button(action: onInfo) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 7) {
                            Text(trainer.name)
                                .font(.system(size: 31, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Text("\(trainer.age)")
                                .font(.system(size: 28, weight: .regular))
                        }

                        Text(trainer.specialization)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(matchScore)%")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("матч")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack(spacing: 8) {
                    Label(String(format: "%.1f", trainer.rating), systemImage: "star.fill")
                    Label(trainer.location, systemImage: "location.fill")
                    if trainer.isOnline {
                        Label("онлайн", systemImage: "circle.fill")
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(18)
        }
    }

    @ViewBuilder
    private var trainerPhoto: some View {
        if let photoName = trainer.photoNames[safe: selectedPhotoIndex] ?? trainer.photoNames.first {
            Image(photoName)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [.blue.opacity(0.92), .cyan.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                Image(systemName: trainer.imageName)
                    .font(.system(size: 144, weight: .light))
                    .foregroundColor(.white.opacity(0.72))
            }
        }
    }
}

struct TrainerStatPill: View {
    let icon: String
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrainerDetailsSection: View {
    let trainer: Trainer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("О тренере")
                    .font(.headline)

                Text(trainer.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FlowTags(tags: trainer.specializationTags)

            VStack(spacing: 10) {
                InfoRow(icon: "person.fill", title: "Пол", value: trainer.gender.title, color: .blue)
                InfoRow(icon: "figure.strengthtraining.traditional", title: "Формат", value: trainer.formats.map(\.title).joined(separator: ", "), color: .green)
                InfoRow(icon: "medal.fill", title: "Достижения", value: trainer.achievements.prefix(2).joined(separator: ", "), color: .orange)
                InfoRow(icon: "bolt.fill", title: "Ответ", value: trainer.responseTime, color: .yellow)
            }
        }
    }
}

struct TrainerAvatarImage: View {
    let trainer: Trainer

    var body: some View {
        if let photoName = trainer.photoNames.first {
            Image(photoName)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: trainer.imageName)
                .font(.system(size: 34))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct MatchBadge: View {
    let score: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(score)%")
                .font(.headline)
                .fontWeight(.bold)

            Text("матч")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .foregroundColor(.green)
        .cornerRadius(12)
    }
}

struct SwipeHint: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 3)
            )
    }
}

struct CircleButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 46, height: 46)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 22)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

struct InsightPill: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(Color(.systemGray6))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct FeatureTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct EmptyTrainersView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.largeTitle)
                .foregroundColor(.gray)

            Text("Тренеры не найдены")
                .font(.headline)

            Text("Попробуйте изменить критерии или вернуть пропущенные анкеты")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Сбросить фильтры") {
                viewModel.resetFilters()
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(36)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
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
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdvancedSearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    filterSummaryCard
                    genderSection
                    ageSection
                    experienceSection
                    formatSection
                    quickSpecializationSection

                    Button(role: .destructive) {
                        viewModel.resetFilters()
                    } label: {
                        Label("Сбросить фильтры", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        viewModel.resetFilters()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filterSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(viewModel.filteredTrainers.count) анкет подходит")
                .font(.title2)
                .fontWeight(.bold)

            Text("Возраст \(viewModel.preferredMinAge)-\(viewModel.preferredMaxAge), стаж от \(viewModel.minTrainerExperience) лет, \(viewModel.selectedTrainerGender.title.lowercased())")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    private var genderSection: some View {
        FilterCard(title: "Пол тренера") {
            HStack(spacing: 8) {
                ForEach(TrainerGender.allCases) { gender in
                    Button(action: { viewModel.selectedTrainerGender = gender }) {
                        Text(gender.title)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedTrainerGender == gender ? .semibold : .regular)
                            .foregroundColor(viewModel.selectedTrainerGender == gender ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(viewModel.selectedTrainerGender == gender ? Color.blue : Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var ageSection: some View {
        FilterCard(title: "Возраст") {
            VStack(spacing: 16) {
                FilterValueRow(title: "От", value: "\(viewModel.preferredMinAge) лет")
                Slider(value: minAgeBinding, in: 18...Double(viewModel.preferredMaxAge), step: 1)

                FilterValueRow(title: "До", value: "\(viewModel.preferredMaxAge) лет")
                Slider(value: maxAgeBinding, in: Double(viewModel.preferredMinAge)...70, step: 1)
            }
        }
    }

    private var experienceSection: some View {
        FilterCard(title: "Стаж работы") {
            VStack(spacing: 12) {
                FilterValueRow(title: "Минимум", value: "\(viewModel.minTrainerExperience) лет")
                Slider(value: experienceBinding, in: 0...25, step: 1)
            }
        }
    }

    private var formatSection: some View {
        FilterCard(title: "Формат тренировок") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(TrainingPlace.allCases) { place in
                    Button(action: { viewModel.selectedPlace = place }) {
                        Text(place.title)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedPlace == place ? .semibold : .regular)
                            .foregroundColor(viewModel.selectedPlace == place ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(viewModel.selectedPlace == place ? Color.blue : Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var quickSpecializationSection: some View {
        FilterCard(title: "Специализация") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(viewModel.quickFilters) { filter in
                    FilterChip(
                        title: filter.name,
                        isSelected: viewModel.selectedFilters.contains(filter)
                    ) {
                        viewModel.toggleFilter(filter)
                    }
                }
            }
        }
    }

    private var minAgeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.preferredMinAge) },
            set: { viewModel.preferredMinAge = min(Int($0), viewModel.preferredMaxAge) }
        )
    }

    private var maxAgeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.preferredMaxAge) },
            set: { viewModel.preferredMaxAge = max(Int($0), viewModel.preferredMinAge) }
        )
    }

    private var experienceBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.minTrainerExperience) },
            set: { viewModel.minTrainerExperience = Int($0) }
        )
    }
}

struct FilterCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

struct FilterValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct MatchQuizView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    let onApply: ((FitnessGoal, TrainingPlace, ClientTrainingExperience, TrainerGender) -> Void)?

    @State private var goal: FitnessGoal
    @State private var place: TrainingPlace
    @State private var experience: ClientTrainingExperience
    @State private var gender: TrainerGender

    init(
        viewModel: HomeViewModel,
        onApply: ((FitnessGoal, TrainingPlace, ClientTrainingExperience, TrainerGender) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onApply = onApply
        _goal = State(initialValue: viewModel.selectedGoal)
        _place = State(initialValue: viewModel.selectedPlace)
        _experience = State(initialValue: viewModel.selectedExperience)
        _gender = State(initialValue: viewModel.selectedTrainerGender)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    quizHeader
                    QuizOptionSection(title: "Главная цель", options: FitnessGoal.allCases, selection: $goal)
                    QuizOptionSection(title: "Где будут тренировки", options: TrainingPlace.allCases, selection: $place)
                    QuizOptionSection(title: "Ваш опыт", options: ClientTrainingExperience.allCases, selection: $experience)
                    QuizOptionSection(title: "Желаемый пол тренера", options: TrainerGender.allCases, selection: $gender)

                    Button(action: applyQuiz) {
                        Text("Показать подходящих тренеров")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.top, 6)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Первичный подбор")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var quizHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("4 вопроса для точного матча")
                .font(.title2)
                .fontWeight(.bold)

            Text("После теста анкеты сортируются по совпадению, а тренер получает ваш запрос только после свайпа вправо.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func applyQuiz() {
        viewModel.applyQuiz(goal: goal, place: place, experience: experience, gender: gender)
        onApply?(goal, place, experience, gender)
        dismiss()
    }
}

struct QuizOptionSection<Option: Identifiable & CaseIterable & Hashable>: View where Option.AllCases: RandomAccessCollection {
    let title: String
    let options: Option.AllCases
    @Binding var selection: Option

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options) { option in
                    Button(action: { selection = option }) {
                        Text(title(for: option))
                            .font(.subheadline)
                            .fontWeight(selection == option ? .semibold : .regular)
                            .foregroundColor(selection == option ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 46)
                            .background(selection == option ? Color.blue : Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func title(for option: Option) -> String {
        if let goal = option as? FitnessGoal { return goal.title }
        if let place = option as? TrainingPlace { return place.title }
        if let experience = option as? ClientTrainingExperience { return experience.title }
        if let gender = option as? TrainerGender { return gender.title }
        return "\(option.id)"
    }
}

struct TrainerDetailView: View {
    let trainer: Trainer
    let matchScore: Int
    let onRequest: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: TrainerDetailTab = .overview

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    trainerHero
                    detailTabs

                    Group {
                        switch selectedTab {
                        case .overview:
                            overviewSection
                        case .pricing:
                            pricingSection
                        case .schedule:
                            scheduleSection
                        case .reviews:
                            reviewsSection
                        }
                    }

                    Button(action: {
                        onRequest()
                        dismiss()
                    }) {
                        Text("Отправить запрос тренеру")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
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

    private var trainerHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                TrainerAvatarImage(trainer: trainer)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(trainer.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(trainer.specialization)
                        .font(.headline)
                        .foregroundColor(.blue)

                    Label(trainer.responseTime, systemImage: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Spacer()

                MatchBadge(score: matchScore)
            }

            Text(trainer.description)
                .font(.body)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                TrainerHeroMetric(title: "Рейтинг", value: String(format: "%.1f", trainer.rating), icon: "star.fill", color: .yellow)
                TrainerHeroMetric(title: "Отзывы", value: "\(trainer.reviewCount)", icon: "text.bubble.fill", color: .blue)
                TrainerHeroMetric(title: "Стаж", value: trainer.experience, icon: "briefcase.fill", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var detailTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TrainerDetailTab.allCases) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.blue : Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }

    private var overviewSection: some View {
        VStack(spacing: 14) {
            detailInfoCard
            achievementsCard
            formatsCard
        }
    }

    private var detailInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация")
                .font(.headline)

            DetailRow(icon: "person.fill", title: "Возраст и пол", value: "\(trainer.age), \(trainer.gender.title)")
            DetailRow(icon: "location.fill", title: "Локация", value: trainer.location)
            DetailRow(icon: "video.fill", title: "Онлайн", value: trainer.availableForOnline ? "Доступно" : "Недоступно")
            DetailRow(icon: "banknote.fill", title: "Базовая цена", value: "\(trainer.price) \(trainer.priceUnit)")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Достижения")
                .font(.headline)

            ForEach(trainer.achievements, id: \.self) { achievement in
                Label(achievement, systemImage: "checkmark.seal.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var formatsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Форматы и специализации")
                .font(.headline)

            FlowTags(tags: trainer.formats.map(\.title) + trainer.specializationTags)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Пакеты занятий")
                .font(.headline)
                .padding(.horizontal)

            ForEach(TrainerOfferPackage.demo(for: trainer)) { package in
                TrainerOfferPackageCard(package: package)
                    .padding(.horizontal)
            }
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ближайшие окна")
                .font(.headline)
                .padding(.horizontal)

            ForEach(TrainerAvailabilitySlot.demo) { slot in
                TrainerAvailabilityCard(slot: slot)
                    .padding(.horizontal)
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отзывы клиентов")
                .font(.headline)
                .padding(.horizontal)

            ForEach(TrainerReview.demo) { review in
                TrainerReviewCard(review: review)
                    .padding(.horizontal)
            }
        }
    }
}

enum TrainerDetailTab: String, CaseIterable, Identifiable {
    case overview
    case pricing
    case schedule
    case reviews

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:
            return "Обзор"
        case .pricing:
            return "Пакеты"
        case .schedule:
            return "Расписание"
        case .reviews:
            return "Отзывы"
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

struct TrainerHeroMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FlowTags: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct TrainerOfferPackage: Identifiable {
    let id: String
    let title: String
    let price: String
    let subtitle: String
    let badge: String?
    let includes: [String]

    static func demo(for trainer: Trainer) -> [TrainerOfferPackage] {
        [
            TrainerOfferPackage(
                id: "trial",
                title: "Пробная тренировка",
                price: "\(max((Int(trainer.price) ?? 1500) / 2, 500)) ₽",
                subtitle: "1 занятие • знакомство и диагностика",
                badge: "-50%",
                includes: ["Разбор цели", "Проверка ограничений", "Мини-план на неделю"]
            ),
            TrainerOfferPackage(
                id: "four",
                title: "Пакет 4 тренировки",
                price: "\((Int(trainer.price) ?? 1500) * 4) ₽",
                subtitle: "4 занятия • действует 30 дней",
                badge: nil,
                includes: ["План тренировок", "Коррекция техники", "Чат между занятиями"]
            ),
            TrainerOfferPackage(
                id: "month",
                title: "Месяц сопровождения",
                price: "\((Int(trainer.price) ?? 1500) * 8) ₽",
                subtitle: "8 занятий + контроль привычек",
                badge: "популярно",
                includes: ["Недельный план", "КБЖУ/шаги", "Еженедельный отчет"]
            )
        ]
    }
}

struct TrainerOfferPackageCard: View {
    let package: TrainerOfferPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(package.title)
                            .font(.headline)

                        if let badge = package.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }

                    Text(package.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(package.price)
                    .font(.headline)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(package.includes, id: \.self) { item in
                    Label(item, systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: {}) {
                Label("Выбрать пакет", systemImage: "creditcard.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerAvailabilitySlot: Identifiable {
    let id: String
    let day: String
    let time: String
    let format: String
    let isBest: Bool

    static let demo = [
        TrainerAvailabilitySlot(id: "1", day: "Сегодня", time: "19:30", format: "Онлайн", isBest: true),
        TrainerAvailabilitySlot(id: "2", day: "Завтра", time: "08:00", format: "Онлайн", isBest: false),
        TrainerAvailabilitySlot(id: "3", day: "Пятница", time: "20:00", format: "Зал", isBest: false)
    ]
}

struct TrainerAvailabilityCard: View {
    let slot: TrainerAvailabilitySlot

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 42, height: 42)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(slot.day)
                        .font(.headline)

                    if slot.isBest {
                        Text("лучшее окно")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(8)
                    }
                }

                Text("\(slot.time) • \(slot.format)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Выбрать") {}
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(9)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerReview: Identifiable {
    let id: String
    let name: String
    let text: String
    let rating: Double
    let result: String

    static let demo = [
        TrainerReview(id: "1", name: "Анна", text: "Понравилось, что план был без перегруза и с понятными домашними заданиями.", rating: 5.0, result: "-4 кг за 6 недель"),
        TrainerReview(id: "2", name: "Михаил", text: "Тренер быстро поправил технику и помог встроить тренировки в рабочий график.", rating: 4.9, result: "12 тренировок подряд"),
        TrainerReview(id: "3", name: "Елена", text: "Очень спокойная коммуникация, всегда понятно, что делать между занятиями.", rating: 4.8, result: "+35% к активности")
    ]
}

struct TrainerReviewCard: View {
    let review: TrainerReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Text(String(review.name.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)

                        Text(String(format: "%.1f", review.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text(review.result)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(8)
            }

            Text(review.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
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

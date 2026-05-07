import SwiftUI

struct TrainingCalendarView: View {
    @EnvironmentObject private var trainingManager: TrainingService
    @EnvironmentObject private var viewModel: TrainingViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingEditView = false
    @State private var showingTrainingPlan = false
    @State private var editingTraining: Training?
    @Environment(\.dismiss) private var dismiss
    
    private let daysOfWeek = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"]
    private let calendar = Calendar.current
    
    private var trainingsForSelectedDate: [Training] {
        trainingManager.getTrainings(for: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator - УБИРАЕМ НЕСУЩЕСТВУЮЩИЙ КОМПОНЕНТ
            // DragIndicator(onTap: { dismiss() })
            
            // Header with month navigation
            headerView

            weeklyPlanCard

            // Days of week
            daysOfWeekView
            
            // Calendar grid
            calendarGridView
            
            // Training details for selected date
            trainingDetailsView
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                // ИСПРАВЛЯЕМ ВЫЗОВ
                TrainingEditView(
                    viewModel: viewModel,
                    training: editingTraining ?? createNewTraining(for: selectedDate)
                )
            }
        }
        .sheet(isPresented: $showingTrainingPlan) {
            TrainingPlanView(
                plan: WeeklyTrainingPlan.demo,
                onAddTraining: addPlanSessionToCalendar
            )
        }
    }
}

// MARK: - Components
extension TrainingCalendarView {
    private var headerView: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(monthYearString(from: currentMonth))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if isToday(selectedDate) {
                    Text("Сегодня")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private var weeklyPlanCard: some View {
        Button(action: { showingTrainingPlan = true }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 46, height: 46)

                    Image(systemName: "calendar.badge.checkmark")
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("План недели")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("3 тренировки • 2 привычки • фокус на мягкий старт")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("67%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("готово")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemGroupedBackground))
    }
    
    private var daysOfWeekView: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var calendarGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date = date {
                    // ЗАМЕНЯЕМ CalendarDayCell на простой компонент
                    DayCell(
                        date: date,
                        isSelected: isSameDay(date, selectedDate),
                        hasTraining: !trainingManager.getTrainings(for: date).isEmpty,
                        isCurrentMonth: isCurrentMonth(date),
                        isToday: isToday(date)
                    ) {
                        selectedDate = date
                    }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var trainingDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text(formattedFullDate(selectedDate))
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: addTraining) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить")
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            if trainingsForSelectedDate.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(trainingsForSelectedDate) { training in
                            // ЗАМЕНЯЕМ TrainingCardView на простой компонент
                            SimpleTrainingCard(
                                training: training,
                                onEdit: {
                                    editingTraining = training
                                    showingEditView = true
                                },
                                onDelete: {
                                    deleteTraining(training)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Нет тренировок")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("На \(formattedDate(selectedDate)) тренировки не запланированы")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: addTraining) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить тренировку")
                }
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}

// ДОБАВЛЯЕМ ПРОСТЫЕ КОМПОНЕНТЫ В КОНЦЕ ФАЙЛА
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasTraining: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayString(from: date))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                if hasTraining {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 44, height: 44)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.5)
        }
        if isSelected {
            return .white
        }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        }
        if isToday {
            return .blue.opacity(0.1)
        }
        return .clear
    }
}

struct SimpleTrainingCard: View {
    let training: Training
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(training.title)
                        .font(.headline)
                    
                    Text(timeString(from: training.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button("Редактировать", action: onEdit)
                    Button("Удалить", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct WeeklyTrainingPlan: Identifiable {
    let id: String
    let title: String
    let trainerName: String
    let focus: String
    let completion: Double
    let sessions: [PlannedTrainingSession]
    let habits: [PlanHabit]

    static let demo = WeeklyTrainingPlan(
        id: "week-1",
        title: "Мягкий старт",
        trainerName: "Ника Морозова",
        focus: "Вернуть регулярность, поднять шаги и не перегрузить суставы.",
        completion: 0.67,
        sessions: [
            PlannedTrainingSession(
                id: "session-1",
                title: "Онлайн-фулбоди",
                dayOffset: 0,
                hour: 19,
                minute: 30,
                type: .strength,
                duration: 45,
                status: .done,
                exercises: ["Разминка 7 мин", "Приседания с весом тела", "Тяга резинки", "Планка 3 подхода"],
                note: "Проверить технику и не гнаться за темпом."
            ),
            PlannedTrainingSession(
                id: "session-2",
                title: "Кардио и шаги",
                dayOffset: 2,
                hour: 20,
                minute: 0,
                type: .cardio,
                duration: 35,
                status: .planned,
                exercises: ["Быстрая ходьба 25 мин", "Легкая мобилизация", "Дыхание 4 минуты"],
                note: "Цель дня: 8 000 шагов."
            ),
            PlannedTrainingSession(
                id: "session-3",
                title: "Растяжка и корпус",
                dayOffset: 4,
                hour: 19,
                minute: 0,
                type: .stretching,
                duration: 30,
                status: .planned,
                exercises: ["Мобилизация таза", "Растяжка задней поверхности", "Dead bug", "Боковая планка"],
                note: "Подойдет как восстановительная тренировка."
            )
        ],
        habits: [
            PlanHabit(id: "habit-1", title: "8 000 шагов", progress: 0.72, icon: "figure.walk"),
            PlanHabit(id: "habit-2", title: "Белок в каждом приеме пищи", progress: 0.6, icon: "fork.knife")
        ]
    )
}

struct PlannedTrainingSession: Identifiable {
    let id: String
    let title: String
    let dayOffset: Int
    let hour: Int
    let minute: Int
    let type: TrainingType
    let duration: Int
    let status: PlanSessionStatus
    let exercises: [String]
    let note: String

    var date: Date {
        let calendar = Calendar.current
        let baseDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) ?? baseDate
    }

    var training: Training {
        Training(
            title: title,
            date: date,
            type: type,
            exercises: exercises.map { Exercise(name: $0, duration: duration / max(exercises.count, 1)) }
        )
    }
}

enum PlanSessionStatus: String {
    case planned = "Запланирована"
    case done = "Выполнена"
    case missed = "Пропущена"

    var icon: String {
        switch self {
        case .planned:
            return "clock.fill"
        case .done:
            return "checkmark.circle.fill"
        case .missed:
            return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .planned:
            return .blue
        case .done:
            return .green
        case .missed:
            return .red
        }
    }
}

struct PlanHabit: Identifiable {
    let id: String
    let title: String
    let progress: Double
    let icon: String
}

struct TrainingPlanView: View {
    let plan: WeeklyTrainingPlan
    let onAddTraining: (PlannedTrainingSession) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    planHeader
                    habitsSection
                    sessionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("План недели")
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

    private var planHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Тренер: \(plan.trainerName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(Int(plan.completion * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("прогресс")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color.green.opacity(0.12))
                .cornerRadius(12)
            }

            Text(plan.focus)
                .font(.subheadline)
                .foregroundColor(.secondary)

            ProgressView(value: plan.completion)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Привычки")
                .font(.headline)

            ForEach(plan.habits) { habit in
                HStack(spacing: 12) {
                    Image(systemName: habit.icon)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(width: 34, height: 34)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(habit.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            Text("\(Int(habit.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        ProgressView(value: habit.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .cornerRadius(14)
            }
        }
    }

    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Тренировки")
                .font(.headline)

            ForEach(plan.sessions) { session in
                PlannedSessionCard(session: session) {
                    onAddTraining(session)
                    dismiss()
                }
            }
        }
    }
}

struct PlannedSessionCard: View {
    let session: PlannedTrainingSession
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)

                    Text("\(formattedDate(session.date)) • \(session.duration) мин")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Label(session.status.rawValue, systemImage: session.status.icon)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(session.status.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(session.status.color.opacity(0.12))
                    .cornerRadius(9)
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(session.exercises, id: \.self) { exercise in
                    Label(exercise, systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(session.note)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Button(action: onAdd) {
                Label("Добавить в календарь", systemImage: "calendar.badge.plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Helper Functions
extension TrainingCalendarView {
    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newDate
    }
    
    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newDate
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date).capitalized
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        let totalDays = 42 // 6 weeks
        
        for offset in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: offset, to: monthFirstWeek.start) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func addTraining() {
        editingTraining = nil
        showingEditView = true
    }
    
    private func createNewTraining(for date: Date) -> Training {
        return Training(
            id: UUID().uuidString,
            title: "Новая тренировка",
            date: date,
            type: .strength
        )
    }

    private func addPlanSessionToCalendar(_ session: PlannedTrainingSession) {
        let training = session.training
        trainingManager.addTraining(training)
        viewModel.saveTraining(training)
        selectedDate = training.date
        currentMonth = training.date
    }
    
    private func saveTraining(_ training: Training) {
            if editingTraining != nil {
                trainingManager.updateTraining(training)
                viewModel.saveTraining(training) // ДОБАВЬ ЭТУ СТРОКУ
            } else {
                trainingManager.addTraining(training)
                viewModel.saveTraining(training) // ДОБАВЬ ЭТУ СТРОКУ
            }
            showingEditView = false
            editingTraining = nil
        }
        
        private func deleteTraining(_ training: Training) {
            trainingManager.deleteTraining(training)
            viewModel.deleteTraining(training) // ДОБАВЬ ЭТУ СТРОКУ
        }
    }

struct TrainingCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let trainingService = TrainingService()

        TrainingCalendarView()
            .environmentObject(trainingService)
            .environmentObject(TrainingViewModel(trainingService: trainingService))
    }
}

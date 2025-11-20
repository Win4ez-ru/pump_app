import SwiftUI

struct TrainingCalendarView: View {
    @EnvironmentObject private var trainingManager: TrainingManager
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingEditView = false
    @State private var editingTraining: Training?
    @Environment(\.dismiss) private var dismiss
    
    private let daysOfWeek = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"]
    private let calendar = Calendar.current
    
    // Вычисляемое свойство для тренировок на выбранную дату
    private var trainingsForSelectedDate: [Training] {
        trainingManager.getTrainings(for: stripTime(from: selectedDate))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Серая полоска для закрытия
            dragIndicator
            
            // Заголовок с навигацией по месяцам
            headerView
            
            // Дни недели
            daysOfWeekView
            
            // Сетка календаря
            calendarGridView
            
            // Детали тренировок на выбранную дату
            trainingDetailsView
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditView) {
            NavigationView {
                TrainingEditView(
                    training: editingTraining ?? createNewTraining(for: selectedDate),
                    onSave: { training in
                        saveTraining(training)
                    }
                )
            }
        }
    }
}

// MARK: - Components
extension TrainingCalendarView {
    
    // Серая полоска для drag жеста
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 6)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .onTapGesture {
                dismiss()
            }
    }
    
    // Заголовок с навигацией по месяцам
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
    
    // Дни недели
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
    
    // Сетка календаря
    private var calendarGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date = date {
                    CalendarDayCell(
                        date: date,
                        isSelected: isSameDay(date, selectedDate),
                        hasTraining: !trainingManager.getTrainings(for: stripTime(from: date)).isEmpty,
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
    
    // Детали тренировок
    private var trainingDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
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
                // Нет тренировок на эту дату
                emptyStateView
            } else {
                // Список тренировок
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(trainingsForSelectedDate) { training in
                            TrainingCardView(
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
    
    // Состояние когда нет тренировок
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
    
    private func stripTime(from date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    private func addTraining() {
        editingTraining = nil
        showingEditView = true
    }
    
    private func createNewTraining(for date: Date) -> Training {
        let startTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
        let endTime = calendar.date(byAdding: .minute, value: 60, to: startTime)!
        
        return Training(
            title: "Новая тренировка",
            description: "",
            exerciseCount: 0,
            duration: 60,
            startTime: startTime,
            endTime: endTime,
            notes: "",
            trainer: "",
            date: stripTime(from: date)
        )
    }
    
    private func saveTraining(_ training: Training) {
        if editingTraining != nil {
            trainingManager.updateTraining(training)
        } else {
            trainingManager.addTraining(training)
        }
        showingEditView = false
        editingTraining = nil
    }
    
    private func deleteTraining(_ training: Training) {
        trainingManager.deleteTraining(training)
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let hasTraining: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let onSelect: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                ZStack {
                    // Фон для сегодняшней даты
                    if isToday {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 32, height: 32)
                    }
                    
                    // Фон для выбранной даты
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(isSelected ? .bold : .medium)
                        .foregroundColor(textColor)
                }
                .frame(height: 32)
                
                // Индикатор тренировки
                if hasTraining {
                    Circle()
                        .fill(isSelected ? Color.white : Color.orange)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}

// MARK: - Training Card View
struct TrainingCardView: View {
    let training: Training
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок карточки
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(training.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(formattedTime(training.startTime)) - \(formattedTime(training.endTime))")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Меню действий
                Menu {
                    Button("Изменить", action: onEdit)
                    Button("Удалить", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(.headline))
                        .foregroundColor(.secondary)
                }
            }
            
            // Детали тренировки
            VStack(alignment: .leading, spacing: 8) {
                if !training.description.isEmpty {
                    Text(training.description)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Статистика
                HStack(spacing: 16) {
                    Label("\(training.exerciseCount) упр.", systemImage: "dumbbell")
                    Label("\(training.duration) мин", systemImage: "clock")
                    
                    if !training.trainer.isEmpty {
                        Label(training.trainer, systemImage: "person.fill")
                    }
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
                
                // Заметки
                if !training.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Заметки:")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text(training.notes)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct TrainingCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingCalendarView()
            .environmentObject(TrainingManager())
    }
}

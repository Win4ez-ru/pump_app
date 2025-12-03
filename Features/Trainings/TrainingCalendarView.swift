import SwiftUI

struct TrainingCalendarView: View {
    @EnvironmentObject private var trainingManager: TrainingService
    @EnvironmentObject private var viewModel: TrainingViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingEditView = false
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
        TrainingCalendarView()
            .environmentObject(TrainingService())
    }
}

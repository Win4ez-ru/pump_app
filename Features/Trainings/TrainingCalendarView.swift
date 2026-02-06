// Features/Trainings/TrainingCalendarView.swift
import SwiftUI

struct TrainingCalendarView: View {
    @EnvironmentObject private var viewModel: TrainingViewModel
    @State private var selectedDate = Date()
    @State private var showingNewTraining = false
    @State private var selectedTraining: Training?
    @State private var showingEditTraining = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Календарь
            CalendarHeader(selectedDate: $selectedDate)
            
            // Список тренировок на выбранный день
            List {
                Section {
                    if trainingsForSelectedDate.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Нет тренировок на этот день")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Нажмите + чтобы добавить тренировку")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .multilineTextAlignment(.center)
                    } else {
                        ForEach(trainingsForSelectedDate) { training in
                            TrainingCalendarRow(
                                training: training,
                                onTap: {
                                    selectedTraining = training
                                    showingEditTraining = true
                                }
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteTraining(training)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Spacer()
        }
        .navigationTitle("Календарь тренировок")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    selectedTraining = nil
                    showingNewTraining = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewTraining) {
            TrainingEditView(viewModel: viewModel, training: selectedTraining)
        }
        .sheet(isPresented: $showingEditTraining) {
            if let training = selectedTraining {
                TrainingEditView(viewModel: viewModel, training: training)
            }
        }
        .onAppear {
            // Убрать сложную логику с UserDefaults
            print("📅 Календарь загружен. Всего тренировок: \(viewModel.trainings.count)")
        }
    }
    
    private var trainingsForSelectedDate: [Training] {
        viewModel.trainingsForDate(selectedDate)
    }
    
    private func deleteTraining(_ training: Training) {
        withAnimation {
            viewModel.deleteTraining(training)
        }
    }
}

// MARK: - Компонент заголовка календаря
struct CalendarHeader: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Месяц и год
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            
            // Дни недели
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Дни месяца
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            isToday: isSameDay(date, Date()),
                            hasTraining: hasTraining(on: date)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: currentMonth).capitalized
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let firstDate = monthFirstWeek.start
        let lastDate = monthLastWeek.end
        
        var dates: [Date?] = []
        var currentDate = firstDate
        
        while currentDate < lastDate {
            if calendar.isDate(currentDate, equalTo: monthInterval.start, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func hasTraining(on date: Date) -> Bool {
        // Более простая реализация
        let trainings = TrainingService.shared.getTrainings(for: date)
        return !trainings.isEmpty
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - Ячейка дня
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTraining: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Круг выделения
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 36, height: 36)
                    } else if isToday {
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                    
                    // Номер дня
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                        .foregroundColor(
                            isSelected ? .white :
                            isToday ? .blue :
                            calendar.isDateInWeekend(date) ? .red :
                            .primary
                        )
                }
                .frame(width: 36, height: 36)
                
                // Индикатор тренировки
                if hasTraining {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Строка тренировки в календаре
struct TrainingCalendarRow: View {
    let training: Training
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Время
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeString)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text(durationString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80, alignment: .leading)
                
                // Основная информация
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(training.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        TrainingTypeBadge(type: training.type)
                    }
                    
                    if !training.exercises.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell")
                                .font(.caption2)
                            
                            Text("\(training.exercises.count) упражнений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: training.date)
    }
    
    private var durationString: String {
        guard !training.exercises.isEmpty else { return "" }
        // Примерная оценка длительности
        let totalExercises = training.exercises.count
        let estimatedMinutes = totalExercises * 5 // 5 минут на упражнение
        return "~\(estimatedMinutes) мин"
    }
}

// MARK: - Предпросмотр
struct TrainingCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainingCalendarView()
                .environmentObject(TrainingViewModel())
        }
    }
}

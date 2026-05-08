import SwiftUI

struct TrainerScheduleDashboard: View {
    @State private var schedule = TrainerScheduleItem.demo
    @State private var selectedDay: TrainerScheduleDay = .today
    @State private var showingAddWindow = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrainerDashboardHeader(
                    title: "Расписание тренера",
                    subtitle: "Сегодня 3 занятия, одно свободное окно вечером.",
                    icon: "calendar.badge.clock",
                    color: .green
                )

                trainerScheduleSummary

                dayPicker

                freeWindowCard

                HStack {
                    Text(selectedDay.title)
                        .font(.headline)

                    Spacer()

                    Button(action: { showingAddWindow = true }) {
                        Label("Окно", systemImage: "plus")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.blue.opacity(0.12))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 2)

                ForEach(daySchedule) { item in
                    TrainerScheduleCard(item: item)
                }

                if daySchedule.isEmpty {
                    TrainerEmptyDayView {
                        showingAddWindow = true
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Календарь")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddWindow = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWindow) {
            TrainerAddScheduleWindowView(selectedDay: selectedDay) { item in
                schedule.append(item)
            }
        }
    }

    private var daySchedule: [TrainerScheduleItem] {
        schedule
            .filter { $0.day == selectedDay }
            .sorted { $0.time < $1.time }
    }

    private var trainerScheduleSummary: some View {
        HStack(spacing: 10) {
            TrainerMetricTile(value: "\(daySchedule.filter { !$0.isOpenWindow }.count)", title: "занятия", color: .blue)
            TrainerMetricTile(value: "\(daySchedule.filter { $0.isOpenWindow }.count)", title: "окна", color: .orange)
            TrainerMetricTile(value: dayLoad, title: "нагрузка", color: .green)
        }
    }

    private var dayLoad: String {
        let minutes = daySchedule.filter { !$0.isOpenWindow }.map(\.minutes).reduce(0, +)
        let hours = Double(minutes) / 60.0
        return String(format: "%.1fч", hours)
    }

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TrainerScheduleDay.allCases) { day in
                    Button(action: { selectedDay = day }) {
                        VStack(spacing: 5) {
                            Text(day.shortTitle)
                                .font(.caption2)
                                .foregroundColor(selectedDay == day ? .white.opacity(0.85) : .secondary)

                            Text(day.dateLabel)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedDay == day ? .white : .primary)
                        }
                        .frame(width: 66, height: 56)
                        .background(selectedDay == day ? Color.blue : Color(.systemBackground))
                        .cornerRadius(14)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var freeWindowCard: some View {
        let openWindow = daySchedule.first { $0.isOpenWindow }

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Свободное окно", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.orange)

                Spacer()

                Text(openWindow?.time ?? "нет")
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(openWindow?.note ?? "На выбранный день пока нет свободного времени. Добавьте окно, чтобы клиенты могли отправлять заявки на пробную тренировку.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                CalendarActionButton(title: "Предложить", icon: "paperplane.fill", color: .blue)
                Button(action: { showingAddWindow = true }) {
                    Label("Добавить", systemImage: "calendar.badge.plus")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerScheduleCard: View {
    let item: TrainerScheduleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Text(item.time)
                        .font(.headline)

                    Text(item.duration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.headline)

                    Text(item.client)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !item.note.isEmpty {
                        Text(item.note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                TrainerTag(title: item.status, color: item.color)
            }

            HStack(spacing: 8) {
                CalendarActionButton(title: item.isOpenWindow ? "Назначить" : "Чат", icon: item.isOpenWindow ? "calendar.badge.plus" : "message.fill", color: .blue)
                CalendarActionButton(title: item.isOpenWindow ? "Блок" : "Перенести", icon: item.isOpenWindow ? "lock.fill" : "arrow.triangle.2.circlepath", color: .orange)
                if !item.isOpenWindow {
                    CalendarActionButton(title: "Готово", icon: "checkmark", color: .green)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

struct TrainerEmptyDayView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.55))

            Text("День свободен")
                .font(.headline)

            Text("Добавьте свободное окно или занятие, чтобы расписание было понятно клиентам.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onAdd) {
                Label("Добавить окно", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerAddScheduleWindowView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDay: TrainerScheduleDay
    let onAdd: (TrainerScheduleItem) -> Void

    @State private var day: TrainerScheduleDay
    @State private var startHour = 18.0
    @State private var duration = 60.0
    @State private var format = "Онлайн"
    @State private var note = "Свободное окно для пробной тренировки."

    private let formats = ["Онлайн", "Зал", "Дома", "Улица", "Созвон"]

    init(selectedDay: TrainerScheduleDay, onAdd: @escaping (TrainerScheduleItem) -> Void) {
        self.selectedDay = selectedDay
        self.onAdd = onAdd
        _day = State(initialValue: selectedDay)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("День")
                            .font(.headline)

                        Picker("День", selection: $day) {
                            ForEach(TrainerScheduleDay.allCases) { day in
                                Text(day.title).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Начало")
                                .font(.headline)

                            Spacer()

                            Text(timeLabel)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        Slider(value: $startHour, in: 6...23, step: 0.5)

                        HStack {
                            Text("Длительность")
                                .font(.headline)

                            Spacer()

                            Text("\(Int(duration)) мин")
                                .font(.headline)
                                .foregroundColor(.green)
                        }

                        Slider(value: $duration, in: 30...120, step: 15)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Формат")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(formats, id: \.self) { option in
                                Button(action: { format = option }) {
                                    HStack {
                                        Text(option)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)

                                        Spacer()

                                        Image(systemName: format == option ? "checkmark.circle.fill" : "circle")
                                    }
                                    .foregroundColor(format == option ? .blue : .primary)
                                    .padding(12)
                                    .background(format == option ? Color.blue.opacity(0.12) : Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Заметка")
                            .font(.headline)

                        TextEditor(text: $note)
                            .frame(minHeight: 90)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    previewCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Новое окно")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addWindow()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var timeLabel: String {
        let hour = Int(startHour)
        let minutes = startHour.truncatingRemainder(dividingBy: 1) == 0 ? "00" : "30"
        return String(format: "%02d:%@", hour, minutes)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Предпросмотр", systemImage: "calendar.badge.clock")
                .font(.headline)
                .foregroundColor(.blue)

            Text("\(day.title), \(timeLabel) • \(Int(duration)) мин")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(format): \(note)")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func addWindow() {
        onAdd(
            TrainerScheduleItem(
                id: UUID().uuidString,
                day: day,
                time: timeLabel,
                title: "Свободное окно",
                client: format,
                status: "open",
                color: .orange,
                duration: "\(Int(duration)) мин",
                minutes: Int(duration),
                note: note,
                isOpenWindow: true
            )
        )
        dismiss()
    }
}

struct TrainerScheduleItem: Identifiable {
    let id: String
    let day: TrainerScheduleDay
    let time: String
    let title: String
    let client: String
    let status: String
    let color: Color
    let duration: String
    let minutes: Int
    let note: String
    let isOpenWindow: Bool

    static let demo = [
        TrainerScheduleItem(
            id: "1",
            day: .today,
            time: "10:00",
            title: "Онлайн-фулбоди",
            client: "Анна",
            status: "подтверждено",
            color: .green,
            duration: "45 мин",
            minutes: 45,
            note: "Проверить технику базовых движений и дать мягкую нагрузку.",
            isOpenWindow: false
        ),
        TrainerScheduleItem(
            id: "2",
            day: .today,
            time: "14:30",
            title: "Питание и план",
            client: "Михаил",
            status: "созвон",
            color: .blue,
            duration: "30 мин",
            minutes: 30,
            note: "Разобрать расписание недели и ограничения по пояснице.",
            isOpenWindow: false
        ),
        TrainerScheduleItem(
            id: "3",
            day: .today,
            time: "19:30",
            title: "Свободное окно",
            client: "можно принять заявку",
            status: "open",
            color: .orange,
            duration: "60 мин",
            minutes: 60,
            note: "Подходит для пробной тренировки нового клиента.",
            isOpenWindow: true
        ),
        TrainerScheduleItem(
            id: "4",
            day: .tomorrow,
            time: "08:00",
            title: "Силовая база",
            client: "Михаил",
            status: "ожидает",
            color: .orange,
            duration: "60 мин",
            minutes: 60,
            note: "Проверить технику приседа и тяги без высокой нагрузки.",
            isOpenWindow: false
        ),
        TrainerScheduleItem(
            id: "5",
            day: .sunday,
            time: "20:00",
            title: "Домашний старт",
            client: "Елена",
            status: "подтверждено",
            color: .green,
            duration: "45 мин",
            minutes: 45,
            note: "Добавить блок корпуса и короткое задание на выходные.",
            isOpenWindow: false
        )
    ]
}

enum TrainerScheduleDay: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    case sunday
    case monday
    case tuesday

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "Сегодня"
        case .tomorrow:
            return "Завтра"
        case .sunday:
            return "Воскресенье"
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        }
    }

    var shortTitle: String {
        switch self {
        case .today:
            return "СЕГ"
        case .tomorrow:
            return "ЗАВ"
        case .sunday:
            return "ВС"
        case .monday:
            return "ПН"
        case .tuesday:
            return "ВТ"
        }
    }

    var dateLabel: String {
        switch self {
        case .today:
            return "8"
        case .tomorrow:
            return "9"
        case .sunday:
            return "10"
        case .monday:
            return "11"
        case .tuesday:
            return "12"
        }
    }
}

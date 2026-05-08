import SwiftUI

@MainActor
final class TrainerClientsViewModel: ObservableObject {
    @Published var clients: [TrainerClientProgress]
    @Published var selectedStatus: TrainerClientStatus = .active
    @Published var selectedClient: TrainerClientProgress?

    init(clients: [TrainerClientProgress] = TrainerClientProgress.demo) {
        self.clients = clients
    }

    var filteredClients: [TrainerClientProgress] {
        clients.filter { $0.status == selectedStatus }
    }

    var activeClientsCount: Int {
        clients.filter { $0.status == .active }.count
    }

    var highRiskClientsCount: Int {
        clients.filter { $0.risk == .high }.count
    }

    var averageProgress: Int {
        guard !clients.isEmpty else { return 0 }
        return clients.map(\.progress).reduce(0, +) / clients.count
    }
}

struct TrainerClientsDashboard: View {
    @StateObject private var viewModel = TrainerClientsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrainerDashboardHeader(
                    title: "Клиенты",
                    subtitle: "Активные подопечные, прогресс и ближайшие действия.",
                    icon: "person.2.fill",
                    color: .purple
                )

                HStack(spacing: 10) {
                    TrainerMetricTile(value: "\(viewModel.activeClientsCount)", title: "активные", color: .blue)
                    TrainerMetricTile(value: "\(viewModel.highRiskClientsCount)", title: "риск", color: .red)
                    TrainerMetricTile(value: "+\(viewModel.averageProgress)%", title: "средний прогресс", color: .green)
                }

                Picker("Статус", selection: $viewModel.selectedStatus) {
                    ForEach(TrainerClientStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(viewModel.filteredClients) { client in
                    TrainerClientProgressCard(client: client) {
                        viewModel.selectedClient = client
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Клиенты")
        .sheet(item: $viewModel.selectedClient) { client in
            TrainerClientDetailView(client: client)
        }
    }
}

struct TrainerClientProgressCard: View {
    let client: TrainerClientProgress
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(client.color.opacity(0.18))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Text(String(client.name.prefix(1)))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(client.color)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(client.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            TrainerTag(title: client.risk.title, color: client.risk.color)
                        }

                        Text(client.goal)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(client.progress)%")
                            .font(.headline)
                            .foregroundColor(.green)

                        Text(client.streak)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                ProgressView(value: Double(client.progress), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: client.risk.color))

                HStack(spacing: 8) {
                    TrainerTag(title: client.nextSession, color: .blue)
                    TrainerTag(title: client.plan, color: .purple)
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrainerClientDetailView: View {
    let client: TrainerClientProgress
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(client.color.opacity(0.18))
                                .frame(width: 68, height: 68)
                                .overlay(Text(String(client.name.prefix(1))).font(.title).fontWeight(.bold).foregroundColor(client.color))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(client.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(client.goal)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack(spacing: 10) {
                            TrainerMetricTile(value: "+\(client.progress)%", title: "прогресс", color: .green)
                            TrainerMetricTile(value: client.streak, title: "серия", color: .orange)
                            TrainerMetricTile(value: client.risk.title, title: "риск", color: client.risk.color)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Рабочая заметка")
                            .font(.headline)

                        Text(client.note)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ближайшие действия")
                            .font(.headline)

                        TrainerRequestDetailRow(title: "Следующее", value: client.nextSession)
                        TrainerRequestDetailRow(title: "План", value: client.plan)
                        TrainerRequestDetailRow(title: "Фокус", value: client.focus)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    HStack(spacing: 10) {
                        CalendarActionButton(title: "Чат", icon: "message.fill", color: .blue)
                        CalendarActionButton(title: "План", icon: "doc.text.fill", color: .purple)
                        CalendarActionButton(title: "Созвон", icon: "phone.fill", color: .green)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Клиент")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}

struct TrainerClientProgress: Identifiable {
    let id: String
    let name: String
    let goal: String
    let progress: Int
    let status: TrainerClientStatus
    let risk: TrainerClientRisk
    let nextSession: String
    let plan: String
    let streak: String
    let note: String
    let focus: String
    let color: Color

    static let demo = [
        TrainerClientProgress(
            id: "1",
            name: "Анна",
            goal: "Минус 4 кг за 8 недель",
            progress: 62,
            status: .active,
            risk: .low,
            nextSession: "Сегодня, 19:30",
            plan: "Мягкий старт",
            streak: "7 дней",
            note: "Хорошо держит шаги, но нужно мягко контролировать колено и не добавлять прыжки.",
            focus: "Техника, шаги, белок в каждом приеме пищи",
            color: .blue
        ),
        TrainerClientProgress(
            id: "2",
            name: "Михаил",
            goal: "Силовая база",
            progress: 48,
            status: .active,
            risk: .medium,
            nextSession: "Завтра, 08:00",
            plan: "Силовая база",
            streak: "3 дня",
            note: "Пропустил одну тренировку из-за работы. Лучше предложить короткий план на занятые дни.",
            focus: "Поясница, базовые движения, нагрузка без рывков",
            color: .purple
        ),
        TrainerClientProgress(
            id: "3",
            name: "Елена",
            goal: "Регулярность",
            progress: 74,
            status: .active,
            risk: .low,
            nextSession: "Пятница, 20:00",
            plan: "Домашний старт",
            streak: "12 дней",
            note: "Отличная регулярность, можно добавить второй блок корпуса и больше самостоятельных заданий.",
            focus: "Домашние тренировки, корпус, привычка",
            color: .green
        ),
        TrainerClientProgress(
            id: "4",
            name: "Игорь",
            goal: "Подготовка к забегу",
            progress: 21,
            status: .paused,
            risk: .high,
            nextSession: "Не назначено",
            plan: "Пауза",
            streak: "0 дней",
            note: "Высокий риск ухода: давно не отвечал, слишком агрессивная цель по срокам.",
            focus: "Вернуть в контакт, пересобрать цель и график",
            color: .orange
        )
    ]
}

enum TrainerClientStatus: String, CaseIterable, Identifiable {
    case active
    case paused

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active:
            return "Активные"
        case .paused:
            return "Пауза"
        }
    }
}

enum TrainerClientRisk {
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low:
            return "низкий"
        case .medium:
            return "средний"
        case .high:
            return "высокий"
        }
    }

    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

import SwiftUI

@MainActor
final class TrainerRequestsViewModel: ObservableObject {
    @Published var requests: [TrainerClientRequest]
    @Published var selectedStatus: TrainerRequestPipelineStatus = .new
    @Published var selectedRequest: TrainerClientRequest?

    init(requests: [TrainerClientRequest] = TrainerClientRequest.demo) {
        self.requests = requests
    }

    var filteredRequests: [TrainerClientRequest] {
        requests.filter { $0.status == selectedStatus }
    }

    var newRequestsCount: Int {
        requests.filter { $0.status == .new }.count
    }

    var acceptedRequestsCount: Int {
        requests.filter { $0.status == .accepted }.count
    }

    var bestMatchScore: Int {
        requests.map(\.matchScore).max() ?? 0
    }
}

struct TrainerRequestsDashboard: View {
    @StateObject private var viewModel = TrainerRequestsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrainerDashboardHeader(
                    title: "Новые заявки",
                    subtitle: "Клиенты, которым вы подошли по цели, формату и опыту.",
                    icon: "tray.full.fill",
                    color: .blue
                )

                HStack(spacing: 10) {
                    TrainerMetricTile(value: "\(viewModel.newRequestsCount)", title: "новые", color: .blue)
                    TrainerMetricTile(value: "\(viewModel.bestMatchScore)%", title: "лучший матч", color: .green)
                    TrainerMetricTile(value: "\(viewModel.acceptedRequestsCount)", title: "приняты", color: .orange)
                }

                Picker("Статус", selection: $viewModel.selectedStatus) {
                    ForEach(TrainerRequestPipelineStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.filteredRequests.isEmpty {
                    TrainerEmptyRequestsView(status: viewModel.selectedStatus)
                } else {
                    ForEach(viewModel.filteredRequests) { request in
                        TrainerRequestLeadCard(request: request) {
                            viewModel.selectedRequest = request
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Заявки")
        .sheet(item: $viewModel.selectedRequest) { request in
            TrainerRequestDetailView(request: request)
        }
    }
}

struct TrainerRequestLeadCard: View {
    let request: TrainerClientRequest
    let onOpenDetails: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(request.color.opacity(0.18))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Text(String(request.clientName.prefix(1)))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(request.color)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(request.clientName)
                            .font(.headline)

                        Text("\(request.age)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    Text(request.goal)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(request.matchScore)%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("матч")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            }

            Text(request.message)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                TrainerTag(title: request.format, color: .blue)
                TrainerTag(title: request.experience, color: .orange)
                TrainerTag(title: "\(request.weeklyGoal)x/нед", color: .green)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    TrainerRequestDetailRow(title: "Ограничения", value: request.limitations)
                    TrainerRequestDetailRow(title: "Удобное время", value: request.preferredTime)
                    TrainerRequestDetailRow(title: "Бюджет", value: request.budget)
                    TrainerRequestDetailRow(title: "Источник", value: request.source)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            Button(action: onOpenDetails) {
                Label("Открыть профиль клиента", systemImage: "person.text.rectangle")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            actionSection
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    @ViewBuilder
    private var actionSection: some View {
        switch request.status {
        case .new:
            HStack(spacing: 10) {
                Button(action: {}) {
                    Label("Отклонить", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: {}) {
                    Label("Принять", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.subheadline)
            .fontWeight(.semibold)

        case .accepted:
            Button(action: {}) {
                Label("Открыть чат с клиентом", systemImage: "message.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color.blue)
                    .cornerRadius(12)
            }

        case .declined:
            Button(action: {}) {
                Label("Вернуть в новые", systemImage: "arrow.counterclockwise")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
}

struct TrainerRequestDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 104, alignment: .leading)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TrainerEmptyRequestsView: View {
    let status: TrainerRequestPipelineStatus

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: status.emptyIcon)
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.55))

            Text(status.emptyTitle)
                .font(.headline)

            Text(status.emptySubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerRequestDetailView: View {
    let request: TrainerClientRequest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    heroSection
                    matchSection
                    clientProfileSection
                    healthAndScheduleSection
                    actionSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Профиль клиента")
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

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(request.color.opacity(0.18))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(String(request.clientName.prefix(1)))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(request.color)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text(request.clientName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(request.age)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    Text(request.goal)
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text(request.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var matchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Совпадение")
                    .font(.headline)

                Spacer()

                Text("\(request.matchScore)%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

            ProgressView(value: Double(request.matchScore), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))

            HStack(spacing: 8) {
                TrainerTag(title: request.format, color: .blue)
                TrainerTag(title: request.experience, color: .orange)
                TrainerTag(title: "\(request.weeklyGoal)x/нед", color: .green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var clientProfileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Анкета клиента")
                .font(.headline)

            TrainerRequestDetailRow(title: "Цель", value: request.goal)
            TrainerRequestDetailRow(title: "Опыт", value: request.experience)
            TrainerRequestDetailRow(title: "Формат", value: request.format)
            TrainerRequestDetailRow(title: "Бюджет", value: request.budget)
            TrainerRequestDetailRow(title: "Источник", value: request.source)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var healthAndScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Перед стартом")
                .font(.headline)

            TrainerRequestDetailRow(title: "Ограничения", value: request.limitations)
            TrainerRequestDetailRow(title: "Время", value: request.preferredTime)

            VStack(alignment: .leading, spacing: 8) {
                Label("Рекомендация", systemImage: "sparkles")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                Text("Начать с короткого созвона, уточнить ограничения и предложить пробную тренировку на 30-45 минут.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    @ViewBuilder
    private var actionSection: some View {
        switch request.status {
        case .new:
            HStack(spacing: 10) {
                Button(action: {}) {
                    Label("Отклонить", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(action: {}) {
                    Label("Принять заявку", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.headline)

        case .accepted:
            Button(action: {}) {
                Label("Открыть чат", systemImage: "message.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blue)
                    .cornerRadius(14)
            }

        case .declined:
            Button(action: {}) {
                Label("Вернуть заявку", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
            }
        }
    }
}

struct TrainerClientRequest: Identifiable {
    let id: String
    let clientName: String
    let age: Int
    let goal: String
    let format: String
    let experience: String
    let weeklyGoal: Int
    let matchScore: Int
    let message: String
    let color: Color
    let status: TrainerRequestPipelineStatus
    let limitations: String
    let preferredTime: String
    let budget: String
    let source: String

    static let demo = [
        TrainerClientRequest(
            id: "1",
            clientName: "Анна",
            age: 24,
            goal: "Похудение и регулярность",
            format: "Онлайн",
            experience: "Начинающий",
            weeklyGoal: 3,
            matchScore: 92,
            message: "Хочу начать без перегруза, подтянуть питание и видеть понятный прогресс.",
            color: .blue,
            status: .new,
            limitations: "Колено после старой травмы, без прыжков",
            preferredTime: "Будни после 19:00",
            budget: "до 2 000 ₽ за занятие",
            source: "Свайп вправо в подборе"
        ),
        TrainerClientRequest(
            id: "2",
            clientName: "Михаил",
            age: 31,
            goal: "Сила и осанка",
            format: "Зал",
            experience: "Тренируюсь",
            weeklyGoal: 2,
            matchScore: 86,
            message: "Нужен тренер, который поможет безопасно вернуться к силовым после перерыва.",
            color: .purple,
            status: .new,
            limitations: "Долгая сидячая работа, иногда болит поясница",
            preferredTime: "Утро или выходные",
            budget: "2 500 ₽ за занятие",
            source: "ML-рекомендация"
        ),
        TrainerClientRequest(
            id: "3",
            clientName: "Елена",
            age: 29,
            goal: "Мягкий старт",
            format: "Дома",
            experience: "С нуля",
            weeklyGoal: 2,
            matchScore: 81,
            message: "Хочу понятный план дома и поддержку между тренировками.",
            color: .green,
            status: .accepted,
            limitations: "Без ограничений",
            preferredTime: "ПН/СР вечером",
            budget: "1 500 ₽ за занятие",
            source: "Принятая заявка"
        ),
        TrainerClientRequest(
            id: "4",
            clientName: "Игорь",
            age: 37,
            goal: "Подготовка к забегу",
            format: "На улице",
            experience: "Опытный",
            weeklyGoal: 4,
            matchScore: 58,
            message: "Ищу тренера для интенсивной подготовки за короткий срок.",
            color: .orange,
            status: .declined,
            limitations: "Нет",
            preferredTime: "Каждый день утром",
            budget: "до 1 000 ₽",
            source: "Отклонено: не совпал формат"
        )
    ]
}

enum TrainerRequestPipelineStatus: String, CaseIterable, Identifiable {
    case new
    case accepted
    case declined

    var id: String { rawValue }

    var title: String {
        switch self {
        case .new:
            return "Новые"
        case .accepted:
            return "Принятые"
        case .declined:
            return "Отклоненные"
        }
    }

    var emptyIcon: String {
        switch self {
        case .new:
            return "tray"
        case .accepted:
            return "checkmark.circle"
        case .declined:
            return "xmark.circle"
        }
    }

    var emptyTitle: String {
        switch self {
        case .new:
            return "Новых заявок нет"
        case .accepted:
            return "Пока нет принятых"
        case .declined:
            return "Отклоненных нет"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .new:
            return "Когда клиент свайпнет вашу анкету вправо, заявка появится здесь."
        case .accepted:
            return "Принятые заявки превращаются в клиентов и чаты."
        case .declined:
            return "Отклоненные заявки можно будет вернуть, если решение изменится."
        }
    }
}

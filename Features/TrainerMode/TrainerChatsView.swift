import SwiftUI

struct TrainerChatsDashboard: View {
    private let chats = TrainerClientChat.demo
    @State private var selectedFilter: TrainerChatFilter = .all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrainerDashboardHeader(
                    title: "Сообщения",
                    subtitle: "Диалоги с клиентами, заявки и быстрые ответы по тренировкам.",
                    icon: "message.fill",
                    color: .blue
                )

                HStack(spacing: 10) {
                    TrainerMetricTile(value: "\(chats.count)", title: "диалога", color: .blue)
                    TrainerMetricTile(value: "\(chats.reduce(0) { $0 + $1.unreadCount })", title: "новых", color: .orange)
                    TrainerMetricTile(value: "\(chats.filter { $0.needsReply }.count)", title: "ответить", color: .red)
                }

                urgentReplyCard

                Picker("Фильтр", selection: $selectedFilter) {
                    ForEach(TrainerChatFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                LazyVStack(spacing: 10) {
                    ForEach(filteredChats) { chat in
                        NavigationLink(destination: TrainerChatDetailView(chat: chat)) {
                            TrainerChatRow(chat: chat)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Чаты")
    }

    private var filteredChats: [TrainerClientChat] {
        switch selectedFilter {
        case .all:
            return chats
        case .needsReply:
            return chats.filter(\.needsReply)
        case .requests:
            return chats.filter { $0.status == .request }
        }
    }

    private var urgentReplyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Нужно ответить", systemImage: "bell.badge.fill")
                    .font(.headline)
                    .foregroundColor(.orange)

                Spacer()

                Text("до 10 мин")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(8)
            }

            Text("Анна уточнила, можно ли перенести пробную тренировку на 20:00. Быстрый ответ поможет не потерять заявку.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                CalendarActionButton(title: "Ответить", icon: "arrowshape.turn.up.left.fill", color: .blue)
                CalendarActionButton(title: "Предложить время", icon: "calendar.badge.plus", color: .green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerChatRow: View {
    let chat: TrainerClientChat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(chat.color.opacity(0.18))
                        .frame(width: 54, height: 54)
                        .overlay(
                            Text(String(chat.clientName.prefix(1)))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(chat.color)
                        )

                    if chat.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 13, height: 13)
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text(chat.clientName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        TrainerTag(title: chat.status.title, color: chat.status.color)
                    }

                    Text(chat.context)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(chat.time)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }

            HStack(spacing: 8) {
                TrainerTag(title: chat.nextAction, color: chat.needsReply ? .orange : .blue)
                TrainerTag(title: chat.nextSession, color: .green)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

struct TrainerChatDetailView: View {
    let chat: TrainerClientChat
    @State private var messages: [TrainerChatMessage]
    @State private var text = ""

    private let quickReplies = [
        "Да, могу в это время",
        "Давайте сначала короткий созвон",
        "Пришлю план сегодня",
        "Отлично, фиксирую тренировку"
    ]

    init(chat: TrainerClientChat) {
        self.chat = chat
        _messages = State(initialValue: chat.messages)
    }

    var body: some View {
        VStack(spacing: 0) {
            trainerClientHeader

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        chatWorkCard

                        ForEach(messages) { message in
                            TrainerMessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            quickRepliesView
            inputBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(chat.clientName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var trainerClientHeader: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(chat.color.opacity(0.18))
                .frame(width: 48, height: 48)
                .overlay(Text(String(chat.clientName.prefix(1))).font(.headline).fontWeight(.bold).foregroundColor(chat.color))

            VStack(alignment: .leading, spacing: 3) {
                Text(chat.clientName)
                    .font(.headline)

                Text(chat.context)
                    .font(.caption)
                    .foregroundColor(.secondary)

                TrainerTag(title: chat.status.title, color: chat.status.color)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "calendar.badge.plus")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var chatWorkCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(chat.nextAction, systemImage: chat.needsReply ? "exclamationmark.message.fill" : "checkmark.message.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(chat.needsReply ? .orange : .blue)

                Spacer()

                Text(chat.nextSession)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text(chat.trainerNote)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .padding(.bottom, 4)
    }

    private var quickRepliesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickReplies, id: \.self) { reply in
                    Button(reply) {
                        text = reply
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Сообщение клиенту", text: $text)
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func sendMessage() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(TrainerChatMessage(id: UUID().uuidString, text: trimmed, time: "сейчас", isFromTrainer: true))
        text = ""
    }
}

struct TrainerMessageBubble: View {
    let message: TrainerChatMessage

    var body: some View {
        HStack {
            if message.isFromTrainer {
                Spacer(minLength: 52)
            }

            VStack(alignment: message.isFromTrainer ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isFromTrainer ? .white : .primary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 10)
                    .background(message.isFromTrainer ? Color.blue : Color(.systemBackground))
                    .cornerRadius(16)

                Text(message.time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !message.isFromTrainer {
                Spacer(minLength: 52)
            }
        }
    }
}

struct TrainerClientChat: Identifiable {
    let id: String
    let clientName: String
    let context: String
    let status: TrainerChatStatus
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let isOnline: Bool
    let needsReply: Bool
    let nextAction: String
    let nextSession: String
    let trainerNote: String
    let color: Color
    let messages: [TrainerChatMessage]

    static let demo = [
        TrainerClientChat(
            id: "1",
            clientName: "Анна",
            context: "Похудение • онлайн • 3x/нед",
            status: .active,
            lastMessage: "Можно сегодня не в 19:30, а ближе к 20:00?",
            time: "12:40",
            unreadCount: 2,
            isOnline: true,
            needsReply: true,
            nextAction: "ответить",
            nextSession: "Сегодня, 19:30",
            trainerNote: "Клиентка мотивирована, но переживает из-за колена. Лучше подтвердить перенос и напомнить, что первая тренировка будет мягкой.",
            color: .blue,
            messages: [
                TrainerChatMessage(id: "1", text: "Анна, привет! Я посмотрела анкету. Начнем с мягкой тренировки без прыжков и резкой нагрузки на колено.", time: "10:12", isFromTrainer: true),
                TrainerChatMessage(id: "2", text: "Супер, спасибо. Можно сегодня не в 19:30, а ближе к 20:00?", time: "12:38", isFromTrainer: false),
                TrainerChatMessage(id: "3", text: "И нужно ли что-то подготовить дома?", time: "12:40", isFromTrainer: false)
            ]
        ),
        TrainerClientChat(
            id: "2",
            clientName: "Михаил",
            context: "Силовая база • зал • 2x/нед",
            status: .request,
            lastMessage: "Хочу сначала понять, подойдет ли мой график.",
            time: "11:05",
            unreadCount: 1,
            isOnline: false,
            needsReply: true,
            nextAction: "назначить созвон",
            nextSession: "Окно завтра, 08:00",
            trainerNote: "Нужно уточнить ограничения по пояснице и предложить короткий созвон до первой тренировки.",
            color: .purple,
            messages: [
                TrainerChatMessage(id: "1", text: "Здравствуйте! Я увидел заявку, по цели и формату мы хорошо совпадаем.", time: "10:50", isFromTrainer: true),
                TrainerChatMessage(id: "2", text: "Хочу сначала понять, подойдет ли мой график.", time: "11:05", isFromTrainer: false)
            ]
        ),
        TrainerClientChat(
            id: "3",
            clientName: "Елена",
            context: "Домашний старт • с нуля",
            status: .active,
            lastMessage: "План на неделю отправила, сегодня просто прогулка и растяжка.",
            time: "вчера",
            unreadCount: 0,
            isOnline: true,
            needsReply: false,
            nextAction: "план отправлен",
            nextSession: "Пятница, 20:00",
            trainerNote: "Хорошо держит регулярность. На следующей тренировке можно добавить блок корпуса.",
            color: .green,
            messages: [
                TrainerChatMessage(id: "1", text: "Как ощущения после первой домашней тренировки?", time: "вчера", isFromTrainer: true),
                TrainerChatMessage(id: "2", text: "Нормально, устала, но без боли.", time: "вчера", isFromTrainer: false),
                TrainerChatMessage(id: "3", text: "План на неделю отправила, сегодня просто прогулка и растяжка.", time: "вчера", isFromTrainer: true)
            ]
        )
    ]
}

struct TrainerChatMessage: Identifiable {
    let id: String
    let text: String
    let time: String
    let isFromTrainer: Bool
}

enum TrainerChatStatus {
    case active
    case request

    var title: String {
        switch self {
        case .active:
            return "клиент"
        case .request:
            return "заявка"
        }
    }

    var color: Color {
        switch self {
        case .active:
            return .green
        case .request:
            return .orange
        }
    }
}

enum TrainerChatFilter: String, CaseIterable, Identifiable {
    case all
    case needsReply
    case requests

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "Все"
        case .needsReply:
            return "Ответить"
        case .requests:
            return "Заявки"
        }
    }
}

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var authManager: AuthService
    var onOpenMatching: () -> Void = {}

    @State private var chats: [Chat] = Chat.demoChats
    @State private var showingNewChat = false

    var body: some View {
        VStack(spacing: 0) {
            if authManager.hasSkippedLogin {
                guestModeView
            } else {
                chatListView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Чаты")
        .sheet(isPresented: $showingNewChat) {
            NewChatView(onOpenMatching: onOpenMatching)
        }
    }

    private var guestModeView: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "message.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))

            VStack(spacing: 8) {
                Text("Чаты после регистрации")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text("После принятия запроса тренером здесь появится переписка, план первой тренировки и быстрые ответы.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: onOpenMatching) {
                Label("Посмотреть подбор", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 220, height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            demoPreview
                .padding(.top, 6)

            Spacer()
        }
        .padding()
    }

    private var demoPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Как это будет выглядеть")
                .font(.headline)

            ChatListItem(chat: Chat.demoChats[0])
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .disabled(true)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var chatListView: some View {
        VStack(spacing: 0) {
            if chats.isEmpty {
                emptyChatsView
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        chatSummary

                        LazyVStack(spacing: 1) {
                            ForEach(chats) { chat in
                                ChatListItem(chat: chat)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }

            newChatButton
        }
    }

    private var chatSummary: some View {
        HStack(spacing: 12) {
            ChatSummaryTile(icon: "message.fill", value: "\(chats.count)", title: "диалога", color: .blue)
            ChatSummaryTile(icon: "bell.fill", value: "\(chats.reduce(0) { $0 + $1.unreadCount })", title: "новых", color: .orange)
            ChatSummaryTile(icon: "calendar.badge.clock", value: "1", title: "план", color: .green)
        }
    }

    private var emptyChatsView: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            VStack(spacing: 8) {
                Text("Пока нет сообщений")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Отправьте запрос тренеру в подборе. Когда тренер примет его, здесь появится чат.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: onOpenMatching) {
                Label("Перейти в подбор", systemImage: "person.crop.rectangle.stack")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 220, height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }

    private var newChatButton: some View {
        Button(action: { showingNewChat = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Новый чат")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct Chat: Identifiable {
    let id: String
    let participantName: String
    let participantAvatar: String
    let specialization: String
    let matchStatus: ChatMatchStatus
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
    let messages: [ChatMessage]

    static let demoChats: [Chat] = [
        Chat(
            id: "1",
            participantName: "Ника Морозова",
            participantAvatar: "person.crop.circle.fill",
            specialization: "Похудение и питание",
            matchStatus: .accepted,
            lastMessage: "Отлично, тогда начнем с мягкой недели и шагов.",
            lastMessageTime: Date().addingTimeInterval(-1200),
            unreadCount: 2,
            messages: [
                ChatMessage(id: "1", text: "Привет! Я посмотрела твой профиль: цель - похудение, формат онлайн, 3 тренировки в неделю.", time: Date().addingTimeInterval(-4200), isFromCurrentUser: false),
                ChatMessage(id: "2", text: "Да, хочу начать без перегруза и понять, как отслеживать питание.", time: Date().addingTimeInterval(-3900), isFromCurrentUser: true),
                ChatMessage(id: "3", text: "Отлично, тогда начнем с мягкой недели и шагов. Я пришлю план первой тренировки и простой шаблон КБЖУ.", time: Date().addingTimeInterval(-1200), isFromCurrentUser: false)
            ]
        ),
        Chat(
            id: "2",
            participantName: "Мария Петрова",
            participantAvatar: "person.crop.circle.fill",
            specialization: "Йога и растяжка",
            matchStatus: .requestPending,
            lastMessage: "Запрос отправлен. Тренер обычно отвечает за 1 час.",
            lastMessageTime: Date().addingTimeInterval(-7200),
            unreadCount: 0,
            messages: [
                ChatMessage(id: "1", text: "Вы отправили запрос тренеру. Когда Мария примет его, здесь откроется полноценный чат.", time: Date().addingTimeInterval(-7200), isFromCurrentUser: false)
            ]
        ),
        Chat(
            id: "3",
            participantName: "Алексей Иванов",
            participantAvatar: "person.crop.circle.fill",
            specialization: "Силовые тренировки",
            matchStatus: .accepted,
            lastMessage: "На первой встрече проверим технику базовых движений.",
            lastMessageTime: Date().addingTimeInterval(-86400),
            unreadCount: 0,
            messages: [
                ChatMessage(id: "1", text: "Привет! Вижу, что тебе интересны силовые и тренировки дома/в зале.", time: Date().addingTimeInterval(-90000), isFromCurrentUser: false),
                ChatMessage(id: "2", text: "Да, хочу понять, как безопасно увеличить нагрузку.", time: Date().addingTimeInterval(-88000), isFromCurrentUser: true),
                ChatMessage(id: "3", text: "На первой встрече проверим технику базовых движений и соберем план на 4 недели.", time: Date().addingTimeInterval(-86400), isFromCurrentUser: false)
            ]
        )
    ]
}

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let time: Date
    let isFromCurrentUser: Bool
}

enum ChatMatchStatus: String {
    case accepted = "Активен"
    case requestPending = "Запрос"

    var color: Color {
        switch self {
        case .accepted:
            return .green
        case .requestPending:
            return .orange
        }
    }

    var icon: String {
        switch self {
        case .accepted:
            return "checkmark.circle.fill"
        case .requestPending:
            return "clock.fill"
        }
    }
}

struct ChatSummaryTile: View {
    let icon: String
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

struct ChatListItem: View {
    let chat: Chat

    private var timeString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(chat.lastMessageTime) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MM"
        }
        return formatter.string(from: chat.lastMessageTime)
    }

    var body: some View {
        NavigationLink(destination: ChatDetailView(chat: chat)) {
            HStack(spacing: 12) {
                Image(systemName: chat.participantAvatar)
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
                    .frame(width: 54, height: 54)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(chat.participantName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(timeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 6) {
                        Label(chat.matchStatus.rawValue, systemImage: chat.matchStatus.icon)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(chat.matchStatus.color)

                        Text(chat.specialization)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if chat.unreadCount > 0 {
                    unreadBadge
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var unreadBadge: some View {
        Text("\(chat.unreadCount)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 22, height: 22)
            .background(Color.blue)
            .clipShape(Circle())
    }
}

struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    let onOpenMatching: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                Image(systemName: "person.crop.rectangle.stack")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)

                VStack(spacing: 8) {
                    Text("Новый чат начинается с матча")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("В клиентском приложении нельзя написать любому тренеру сразу. Сначала отправьте запрос в подборе, а чат откроется после принятия.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: {
                    dismiss()
                    onOpenMatching()
                }) {
                    Label("Перейти в подбор", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Новый чат")
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

struct ChatDetailView: View {
    let chat: Chat
    @State private var messages: [ChatMessage]
    @State private var messageText = ""

    private let quickReplies = [
        "Когда удобно созвониться?",
        "Пришлите план первой тренировки",
        "Хочу обсудить питание"
    ]

    init(chat: Chat) {
        self.chat = chat
        _messages = State(initialValue: chat.messages)
    }

    var body: some View {
        VStack(spacing: 0) {
            trainerHeader

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
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
        .navigationTitle(chat.participantName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var trainerHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: chat.participantAvatar)
                .font(.system(size: 34))
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(chat.specialization)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Label(chat.matchStatus.rawValue, systemImage: chat.matchStatus.icon)
                    .font(.caption)
                    .foregroundColor(chat.matchStatus.color)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "calendar.badge.plus")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var quickRepliesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickReplies, id: \.self) { reply in
                    Button(reply) {
                        messageText = reply
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Сообщение", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(
            ChatMessage(
                id: UUID().uuidString,
                text: trimmed,
                time: Date(),
                isFromCurrentUser: true
            )
        )
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 44)
            }

            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(message.isFromCurrentUser ? Color.blue : Color(.systemBackground))
                    .cornerRadius(14)

                Text(formatTime(message.time))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !message.isFromCurrentUser {
                Spacer(minLength: 44)
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatListView()
                .environmentObject(AuthService())
        }
    }
}

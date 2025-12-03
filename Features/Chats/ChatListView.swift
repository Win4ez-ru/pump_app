import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var authManager: AuthService
    @State private var chats: [Chat] = []
    @State private var showingNewChat = false
    
    var body: some View {
        VStack(spacing: 0) {
            if authManager.hasSkippedLogin {
                guestModeView
            } else {
                chatListView
            }
        }
        .navigationTitle("Чаты")
        .sheet(isPresented: $showingNewChat) {
            NewChatView()
        }
        .onAppear {
            loadChats()
        }
    }
    
    private var guestModeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "message.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("Доступно после регистрации")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Функция чатов доступна только для зарегистрированных пользователей")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                // Здесь будет переход к регистрации
                print("Переход к регистрации из чатов")
            }) {
                Text("Зарегистрироваться")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
    
    private var chatListView: some View {
        VStack(spacing: 0) {
            if chats.isEmpty {
                emptyChatsView
            } else {
                chatList
            }
            
            // New chat button
            if !authManager.hasSkippedLogin {
                newChatButton
            }
        }
    }
    
    private var emptyChatsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Нет сообщений")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Начните общение с тренером или другими пользователями")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var chatList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(chats) { chat in
                    ChatListItem(chat: chat)
                }
            }
            .background(Color(.systemBackground))
        }
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
    }
    
    private func loadChats() {
        // Заглушка с демо-чатами
        if !authManager.hasSkippedLogin {
            chats = [
                Chat(
                    id: "1",
                    participantName: "Иван Петров",
                    participantAvatar: "person.circle.fill",
                    lastMessage: "Привет! Как твои тренировки?",
                    lastMessageTime: Date().addingTimeInterval(-3600),
                    unreadCount: 2
                ),
                Chat(
                    id: "2",
                    participantName: "Мария Сидорова",
                    participantAvatar: "person.circle.fill",
                    lastMessage: "Не забудь про завтрашнюю тренировку",
                    lastMessageTime: Date().addingTimeInterval(-7200),
                    unreadCount: 0
                ),
                Chat(
                    id: "3",
                    participantName: "Алексей Козлов",
                    participantAvatar: "person.circle.fill",
                    lastMessage: "Отличная работа на последней тренировке!",
                    lastMessageTime: Date().addingTimeInterval(-86400),
                    unreadCount: 1
                )
            ]
        }
    }
}

// MARK: - Chat Models
struct Chat: Identifiable {
    let id: String
    let participantName: String
    let participantAvatar: String
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
}

// MARK: - Chat List Item
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
                // Avatar
                Image(systemName: chat.participantAvatar)
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.participantName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(timeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            .frame(width: 20, height: 20)
            .background(Color.blue)
            .clipShape(Circle())
    }
}

// MARK: - Placeholder Views
struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Выбор собеседника")
                    .foregroundColor(.secondary)
                Spacer()
            }
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
    
    var body: some View {
        VStack {
            Text("Чат с \(chat.participantName)")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle(chat.participantName)
        .navigationBarTitleDisplayMode(.inline)
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

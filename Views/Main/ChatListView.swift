import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            if authManager.hasSkippedLogin {
                // Сообщение для гостевого режима
                VStack(spacing: 15) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("Доступно после регистрации")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Функция чатов доступна только для зарегистрированных пользователей")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Зарегистрироваться") {
                        // Здесь будет переход к регистрации
                        print("Переход к регистрации из чатов")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 10)
                }
                .padding()
            } else {
                // Список чатов для зарегистрированных пользователей
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { index in
                            ChatListItem(
                                name: "Пользователь \(index)",
                                lastMessage: "Последнее сообщение \(index)",
                                time: "12:3\(index)",
                                unread: index == 1
                            )
                        }
                    }
                    .padding()
                }
                
                // Кнопка нового чата
                Button {
                    print("Новый чат")
                } label: {
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
        }
        .navigationTitle("Чаты")
    }
}

// Компонент элемента списка чатов
struct ChatListItem: View {
    let name: String
    let lastMessage: String
    let time: String
    let unread: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            Image(systemName: "person.circle.fill")
                .font(.system(size: 45))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if unread {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
            .environmentObject(AuthManager())
    }
}
